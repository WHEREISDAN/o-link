local RESOURCE = 'qb-core'

if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Multichar', RESOURCE, RESOURCE) then return end

local function isStarted()
    return GetResourceState(RESOURCE) == 'started'
end

local QBCore
CreateThread(function()
    while GetResourceState(RESOURCE) ~= 'started' do Wait(100) end
    local ok, core = pcall(function() return exports[RESOURCE]:GetCoreObject() end)
    if ok then QBCore = core end
end)

local function safeDecode(value)
    if type(value) == 'string' then
        local ok, decoded = pcall(json.decode, value)
        if ok then return decoded end
        return nil
    end
    return value
end

local function toSlot(row)
    local charinfo = safeDecode(row.charinfo) or {}
    local pos = safeDecode(row.position) or {}
    local first = charinfo.firstname or ''
    local last = charinfo.lastname or ''
    return {
        charId     = row.citizenid,
        -- QBCore has no separate state-id column; citizenid is the public-facing
        -- ID surfaced as "State ID" everywhere in the QB ecosystem.
        stateId    = row.citizenid,
        firstName  = charinfo.firstname,
        lastName   = charinfo.lastname,
        fullName   = (first .. ' ' .. last):gsub('^%s+', ''):gsub('%s+$', ''),
        dob        = charinfo.birthdate,
        gender     = tonumber(charinfo.gender) or 0,
        position   = { x = pos.x, y = pos.y, z = pos.z, w = pos.w or pos.heading },
        lastPlayed = row.last_updated and tonumber(row.last_updated) or nil,
    }
end

local function getLicense(src)
    if QBCore and QBCore.Functions then
        return QBCore.Functions.GetIdentifier(src, 'license')
    end
    return GetPlayerIdentifierByType(src, 'license')
end

---Block until QBCore.Player.Login fires PlayerLoaded for this source, with a
---timeout so the callback doesn't hang if Login bailed silently.
---@param src number
---@param timeoutMs? number
---@return boolean loaded
local function waitForLoad(src, timeoutMs)
    local deadline = GetGameTimer() + (timeoutMs or 5000)
    while GetGameTimer() < deadline do
        if QBCore and QBCore.Functions then
            local player = QBCore.Functions.GetPlayer(src)
            if player and player.PlayerData and player.PlayerData.citizenid then
                return true
            end
        end
        Wait(50)
    end
    return false
end

olink._register('multichar', {
    GetResourceName = function() return RESOURCE end,

    List = function(src)
        if not isStarted() then return {} end
        local license = getLicense(src)
        local rows = MySQL.query.await(
            'SELECT citizenid, charinfo, position, last_updated FROM players WHERE license = ? ORDER BY cid ASC',
            { license or '__none__' }
        )
        if not rows then return {} end
        local result = {}
        for _, row in ipairs(rows) do
            result[#result + 1] = toSlot(row)
        end
        return result
    end,

    Create = function(src, data)
        if not isStarted() or not QBCore then return { ok = false, error = 'qb-core not started' } end

        local newData = {
            cid = 1,
            charinfo = {
                firstname   = data.firstName,
                lastname    = data.lastName,
                birthdate   = data.dob,
                gender      = tonumber(data.gender) or 0,
                nationality = data.nationality or '',
            },
        }

        local ok, success = pcall(function() return QBCore.Player.Login(src, false, newData) end)
        if not ok or not success then return { ok = false, error = 'QBCore Login failed' } end

        if not waitForLoad(src) then return { ok = false, error = 'Player did not load' } end

        -- Login only authenticates. The client onboard step (OnboardNewCharacter)
        -- fires QBCore:Client:OnPlayerLoaded after spawn/apartment selection,
        -- mirroring native qb-multicharacter/qb-spawn (which never fire it from
        -- Login). Firing it here too would double up with the onboard step.
        local player = QBCore.Functions.GetPlayer(src)
        local charId = player and player.PlayerData and player.PlayerData.citizenid
        return { ok = true, charId = charId }
    end,

    Select = function(src, charId)
        if not isStarted() or not QBCore then return { ok = false, error = 'qb-core not started' } end

        local cid = tostring(charId)

        -- Short-circuit if the player is already loaded with this citizenid.
        -- oxide-multichar's creator flow calls Create immediately before Select,
        -- and Create already calls Login() once. Calling Login() a second time
        -- with the same source corrupts state (QBCore wipes the player object
        -- mid-load).
        local existing = QBCore.Functions.GetPlayer(src)
        if existing and existing.PlayerData and existing.PlayerData.citizenid == cid then
            local p = existing.PlayerData.position
            return { ok = true, position = p and { x = p.x, y = p.y, z = p.z, w = p.w } or nil }
        end

        -- Ownership check: the citizenid must belong to this license, otherwise a
        -- client could forge any cid and log into another player's character.
        local owned = MySQL.scalar.await(
            'SELECT 1 FROM players WHERE citizenid = ? AND license = ? LIMIT 1',
            { cid, getLicense(src) or '__none__' }
        )
        if not owned then return { ok = false, error = 'Character not owned' } end

        local ok, success = pcall(function() return QBCore.Player.Login(src, cid) end)
        if not ok or not success then return { ok = false, error = 'QBCore Login failed' } end

        if not waitForLoad(src) then return { ok = false, error = 'Player did not load' } end

        -- Login only authenticates. The client spawn step (SpawnCharacter) fires
        -- QBCore:Client:OnPlayerLoaded after the spawn is resolved.
        local player = QBCore.Functions.GetPlayer(src)
        local pos
        if player and player.PlayerData and player.PlayerData.position then
            local p = player.PlayerData.position
            pos = { x = p.x, y = p.y, z = p.z, w = p.w }
        end

        return { ok = true, position = pos }
    end,

    Delete = function(src, charId)
        if not isStarted() or not QBCore then return false end
        local cid = tostring(charId)

        -- Owner check: prevent deleting a character belonging to another license.
        local row = MySQL.single.await('SELECT license FROM players WHERE citizenid = ?', { cid })
        if not row or row.license ~= getLicense(src) then return false end

        local ok = pcall(function() QBCore.Player.DeleteCharacter(src, cid) end)
        if not ok then return false end

        -- DeleteCharacter runs an async MySQL.transaction and returns nothing, so
        -- its return value can't signal success (the old `result == true` check
        -- always failed, surfacing a false "delete failed" even though the row was
        -- removed). Wait until the authoritative row is actually gone: this reports
        -- real success and keeps the list refresh that fires right after from
        -- racing the transaction and re-showing the deleted character.
        local deadline = GetGameTimer() + 2000
        repeat
            Wait(50)
            if not MySQL.scalar.await('SELECT 1 FROM players WHERE citizenid = ? LIMIT 1', { cid }) then
                return true
            end
        until GetGameTimer() > deadline
        return false
    end,

    ---Returns the number of existing characters. The maximum is configured in
    ---oxide-multichar's config.lua (Config.MaxCharacters); this adapter never
    ---touches slot-max policy.
    GetSlotInfo = function(src)
        if not isStarted() then return { used = 0 } end
        local license = getLicense(src)
        local row = MySQL.single.await(
            'SELECT COUNT(*) AS used FROM players WHERE license = ?',
            { license or '__none__' }
        )
        return { used = (row and row.used) or 0 }
    end,

    Logout = function(src)
        if not isStarted() or not QBCore then return false end
        local ok = pcall(function() QBCore.Player.Logout(src) end)
        if ok then
            TriggerClientEvent('o-link:multichar:startSelect', src)
            return true
        end
        return false
    end,
})
