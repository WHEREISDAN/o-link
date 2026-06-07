if not olink._guardImpl('Multichar', 'oxide-core', 'oxide-core') then return end

local Oxide = exports['oxide-core']:Core()

---@param src number
---@return table|nil player
local function GetPlayer(src)
    return Oxide.Functions.GetPlayer(src)
end

---Normalize an Oxide character object to the cross-framework slot DTO.
---@param char table
---@return table
local function toSlot(char)
    return {
        charId     = char.charId,
        stateId    = char.stateId,
        firstName  = char.firstName,
        lastName   = char.lastName,
        fullName   = char.fullName or ((char.firstName or '') .. ' ' .. (char.lastName or '')),
        dob        = char.dateOfBirth or char.dob,
        gender     = char.gender,
        position   = char.position,
        lastPlayed = char.lastPlayed,
    }
end

---Find a character owned by the player by its charId. NUI round-trips numeric
---ids as floats (2.0), so compare numerically.
---@param player table
---@param charId any
---@return table|nil
local function findOwned(player, charId)
    local target = tonumber(charId) or charId
    for _, char in ipairs(player.GetCharacters()) do
        if char.charId == target then
            return char
        end
    end
    return nil
end

olink._register('multichar', {
    ---@return string
    GetResourceName = function() return 'oxide-core' end,

    ---@param src number
    ---@return table[] slot DTOs sorted oldest-first
    List = function(src)
        local player = GetPlayer(src)
        if not player then return {} end

        local result = {}
        for _, char in ipairs(player.GetCharacters()) do
            result[#result + 1] = toSlot(char)
        end
        table.sort(result, function(a, b) return (a.charId or 0) < (b.charId or 0) end)
        return result
    end,

    ---@param src number
    ---@param data table { firstName, lastName, dob, gender }
    ---@return table { ok, charId?, error? }
    Create = function(src, data)
        local player = GetPlayer(src)
        if not player then return { ok = false, error = 'No player' } end

        if not player.CanCreateCharacter() then
            return { ok = false, error = 'Maximum character limit reached' }
        end

        local character = Oxide.Functions.CreateCharacter(player.userId, {
            firstName   = data.firstName,
            lastName    = data.lastName,
            dateOfBirth = data.dob,
            gender      = data.gender,
        })

        if not character then return { ok = false, error = 'Failed to create character' } end

        local characters = player.GetCharacters()
        characters[#characters + 1] = character
        player.SetCharacters(characters)

        TriggerEvent('oxide:core:characterCreated', src, character)

        return { ok = true, charId = character.charId }
    end,

    ---Set a character active, push client load, fire the ready event, and return
    ---the spawn position so the consumer can teleport (Oxide has no spawn manager).
    ---@param src number
    ---@param charId any
    ---@return table { ok, position?, error? }
    Select = function(src, charId)
        local player = GetPlayer(src)
        if not player then return { ok = false, error = 'No player' } end

        local owned = findOwned(player, charId)
        if not owned then
            return { ok = false, error = 'Character not owned' }
        end

        -- Prefer fresh data from the store; fall back to the owned reference.
        local character = Oxide.Functions.GetCharacter(owned.charId) or owned

        player.SetActiveCharacter(character)
        TriggerClientEvent('oxide:core:characterLoaded', src, character.ToClientData())
        TriggerEvent('oxide:core:playerReady', src, player, character)

        return { ok = true, position = character.position }
    end,

    ---@param src number
    ---@param charId any
    ---@return boolean
    Delete = function(src, charId)
        local player = GetPlayer(src)
        if not player then return false end

        local owned = findOwned(player, charId)
        if not owned then return false end

        local active = player.GetCharacter()
        if active and active.charId == owned.charId then return false end

        if not Oxide.Functions.DeleteCharacter(owned.charId) then return false end

        local characters = player.GetCharacters()
        for i, char in ipairs(characters) do
            if char.charId == owned.charId then
                table.remove(characters, i)
                break
            end
        end
        player.SetCharacters(characters)

        TriggerEvent('oxide:core:characterDeleted', src, owned.charId)
        return true
    end,

    ---Returns the number of existing characters. The maximum is configured in
    ---oxide-multichar's config.lua (Config.MaxCharacters); this adapter never
    ---touches slot-max policy.
    ---@param src number
    ---@return table { used }
    GetSlotInfo = function(src)
        local player = GetPlayer(src)
        if not player then return { used = 0 } end
        local used = player.GetCharacterSlots()
        return { used = used or 0 }
    end,

    ---Clear the active character and return the client to selection.
    ---@param src number
    ---@return boolean
    Logout = function(src)
        local player = GetPlayer(src)
        if not player then return false end

        local character = player.GetCharacter()
        if character then
            TriggerEvent('oxide:core:characterUnloading', src, player, character)
            -- Persist before unload. SetActiveCharacter(nil) clears statebags but
            -- never saves, so without this the logout-to-selection path loses
            -- everything since the last autosave tick (QBX/ESX save on logout).
            Oxide.Functions.SaveCharacter(character)
        end

        player.SetActiveCharacter(nil)
        TriggerClientEvent('o-link:multichar:startSelect', src)
        return true
    end,
})
