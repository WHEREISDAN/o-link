local RESOURCE = 'qbx_core'

if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Multichar', RESOURCE, RESOURCE) then return end

local function isStarted()
    return GetResourceState(RESOURCE) == 'started'
end

-- QBX exposes character lifecycle as server-side `lib.callback`s registered on
-- qbx_core. ox_lib callbacks can only cross the client<->server boundary, so
-- Create and Select are bridged through this adapter's client.lua. List,
-- Delete, GetSlotInfo, and Logout run directly server-side via DB / exports.

local function safeDecode(value)
    if type(value) == 'string' then
        local ok, decoded = pcall(json.decode, value)
        if ok then return decoded end
        return nil
    end
    return value
end

---@param row table players row
---@return table slot DTO
local function toSlot(row)
    local charinfo = safeDecode(row.charinfo) or {}
    local pos = safeDecode(row.position) or {}
    local first = charinfo.firstname or ''
    local last = charinfo.lastname or ''
    return {
        charId     = row.citizenid,
        -- QBX has no separate state-id column; citizenid is the public-facing
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

---@param src number
---@return string|nil, string|nil license2, license
local function getLicenses(src)
    return GetPlayerIdentifierByType(src, 'license2'), GetPlayerIdentifierByType(src, 'license')
end

olink._register('multichar', {
    GetResourceName = function() return RESOURCE end,

    List = function(src)
        if not isStarted() then return {} end
        local license2, license = getLicenses(src)
        local rows = MySQL.query.await(
            'SELECT citizenid, charinfo, position, last_updated FROM players WHERE license = ? OR license = ? ORDER BY cid ASC',
            { license2 or '__none__', license or '__none__' }
        )
        if not rows then return {} end
        local result = {}
        for _, row in ipairs(rows) do
            result[#result + 1] = toSlot(row)
        end
        return result
    end,

    Create = function(src, data)
        if not isStarted() then return { ok = false, error = 'qbx_core not started' } end

        local payload = {
            firstname   = data.firstName,
            lastname    = data.lastName,
            birthdate   = data.dob,
            gender      = tonumber(data.gender) or 0,
            nationality = data.nationality or '',
        }

        local ok, newData = pcall(function()
            return lib.callback.await('o-link:multichar:qbx:create', src, payload)
        end)
        if not ok or not newData then return { ok = false, error = 'QBX createCharacter failed' } end

        -- Login only authenticates here. QBCore:Client:OnPlayerLoaded is fired
        -- by the client onboard step (OnboardNewCharacter), mirroring native
        -- QBX where spawnDefault()/apartments fire it after spawn — never from
        -- Login itself.
        local charId
        local okPlayer, player = pcall(function() return exports.qbx_core:GetPlayer(src) end)
        if okPlayer and player and player.PlayerData then
            charId = player.PlayerData.citizenid
        end

        return { ok = true, charId = charId or newData.citizenid }
    end,

    Select = function(src, charId)
        if not isStarted() then return { ok = false, error = 'qbx_core not started' } end

        local cid = tostring(charId)

        -- Short-circuit if the player is already loaded with this citizenid.
        -- Hit by oxide-multichar's creator flow: Create runs immediately before
        -- Select, and QBX's createCharacter callback already calls Login(),
        -- populating QBX.Players[src]. A second Login from loadCharacter trips
        -- QBX's anti-cheat ("Dropped for attempting to login twice").
        local okPlayer, player = pcall(function() return exports.qbx_core:GetPlayer(src) end)
        if okPlayer and player and player.PlayerData and player.PlayerData.citizenid == cid then
            local p = player.PlayerData.position
            return { ok = true, position = p and { x = p.x, y = p.y, z = p.z, w = p.w } or nil }
        end

        local ok, success = pcall(function()
            return lib.callback.await('o-link:multichar:qbx:select', src, cid)
        end)
        if not ok or not success then return { ok = false, error = 'QBX loadCharacter failed' } end

        -- Login only authenticates. The client spawn step (SpawnCharacter) fires
        -- QBCore:Client:OnPlayerLoaded after the spawn is resolved — matching
        -- native QBX, which fires it from the spawn selector / spawnLastLocation.
        local pos
        local okPlayer2, player2 = pcall(function() return exports.qbx_core:GetPlayer(src) end)
        if okPlayer2 and player2 and player2.PlayerData and player2.PlayerData.position then
            local p = player2.PlayerData.position
            pos = { x = p.x, y = p.y, z = p.z, w = p.w }
        end

        return { ok = true, position = pos }
    end,

    Delete = function(src, charId)
        if not isStarted() then return false end
        local cid = tostring(charId)

        -- Owner check: prevent deleting characters belonging to another license.
        local row = MySQL.single.await('SELECT license FROM players WHERE citizenid = ?', { cid })
        if not row then return false end
        local license2, license = getLicenses(src)
        if row.license ~= license2 and row.license ~= license then return false end

        local ok = pcall(function() exports.qbx_core:DeleteCharacter(cid) end)
        return ok
    end,

    ---Returns the number of existing characters. The maximum is configured in
    ---oxide-multichar's config.lua (Config.MaxCharacters); this adapter never
    ---touches slot-max policy.
    GetSlotInfo = function(src)
        if not isStarted() then return { used = 0 } end
        local license2, license = getLicenses(src)
        local row = MySQL.single.await(
            'SELECT COUNT(*) AS used FROM players WHERE license = ? OR license = ?',
            { license2 or '__none__', license or '__none__' }
        )
        return { used = (row and row.used) or 0 }
    end,

    Logout = function(src)
        if not isStarted() then return false end
        local ok = pcall(function() exports.qbx_core:Logout(src) end)
        if ok then
            -- QBX fires qbx_core:client:playerLoggedOut from Logout(), which the
            -- client adapter bridges to olink:client:startCharacterSelect.
            return true
        end
        return false
    end,
})
