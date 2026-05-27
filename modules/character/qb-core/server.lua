if not olink._guardImpl('Character', 'qb-core', 'qb-core') then return end
if not olink._hasOverride('Character') and GetResourceState('qbx_core') == 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

---@param src number
---@return table|nil
local function GetPlayer(src)
    return QBCore.Functions.GetPlayer(src)
end

olink._register('character', {
    ---@param src number
    ---@return string|nil
    GetIdentifier = function(src)
        local player = GetPlayer(src)
        if not player then return nil end
        return player.PlayerData.citizenid
    end,

    ---@param src number
    ---@return string|nil firstName, string|nil lastName
    GetName = function(src)
        local player = GetPlayer(src)
        if not player then return nil, nil end
        local charinfo = player.PlayerData.charinfo
        return charinfo.firstname, charinfo.lastname
    end,

    ---@param src number
    ---@param key string
    ---@return any|nil
    GetMetadata = function(src, key)
        local player = GetPlayer(src)
        if not player then return nil end
        return player.PlayerData.metadata[key]
    end,

    ---@param src number
    ---@param key string
    ---@param value any
    ---@return boolean
    SetMetadata = function(src, key, value)
        local player = GetPlayer(src)
        if not player then return false end
        player.Functions.SetMetaData(key, value)
        return true
    end,

    ---@param src number
    ---@return table|nil
    GetAllMetadata = function(src)
        local player = GetPlayer(src)
        if not player then return nil end
        return player.PlayerData.metadata
    end,

    ---@param src number
    ---@param isBoss boolean
    ---@return boolean
    SetBoss = function(src, isBoss)
        local player = GetPlayer(src)
        if not player then return false end
        player.Functions.SetMetaData('isboss', isBoss)
        return true
    end,

    ---@param src number
    ---@return boolean
    IsBoss = function(src)
        local player = GetPlayer(src)
        if not player then return false end
        return player.PlayerData.job.isboss or false
    end,

    ---Search players by citizenid (prefix), charinfo first/last name, full
    ---name in either order, or phone number. LIKE wildcards in user input are
    ---escaped.
    ---@param query string
    ---@param limit number|nil
    ---@return table[]
    Search = function(query, limit)
        limit = limit or 20
        local q = type(query) == 'string' and query:match('^%s*(.-)%s*$') or ''
        if #q < 2 then return {} end

        local escaped = q:gsub('\\', '\\\\'):gsub('([%%_])', '\\%1')
        local like    = '%' .. escaped .. '%'
        local prefix  = escaped .. '%'

        local rows = MySQL.query.await([[
            SELECT citizenid, charinfo, job, last_updated
            FROM players
            WHERE citizenid LIKE ?
               OR JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')) LIKE ?
               OR JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname'))  LIKE ?
               OR CONCAT(
                    JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')), ' ',
                    JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname'))
                  ) LIKE ?
               OR CONCAT(
                    JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname')), ' ',
                    JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname'))
                  ) LIKE ?
               OR JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.phone')) LIKE ?
            ORDER BY last_updated DESC
            LIMIT ?
        ]], { prefix, like, like, like, like, like, limit })

        if not rows then return {} end

        local results = {}
        for _, row in ipairs(rows) do
            local charinfo = type(row.charinfo) == 'string' and json.decode(row.charinfo) or row.charinfo or {}
            local job = type(row.job) == 'string' and json.decode(row.job) or row.job or {}
            results[#results + 1] = {
                charId    = row.citizenid,
                firstName = charinfo.firstname,
                lastName  = charinfo.lastname,
                dob       = charinfo.birthdate,
                gender    = (charinfo.gender == 1 or charinfo.gender == 'female') and 1 or 0,
                stateId   = row.citizenid,
                job       = { name = job.name, label = job.label, grade = job.grade and job.grade.name, gradeLabel = job.grade and job.grade.name, rank = job.grade and job.grade.level or 0 },
            }
        end
        return results
    end,

    ---@param charId string citizenid
    ---@return table|nil
    GetOffline = function(charId)
        local row = MySQL.single.await('SELECT citizenid, charinfo, job FROM players WHERE citizenid = ?', { charId })
        if not row then return nil end

        local charinfo = type(row.charinfo) == 'string' and json.decode(row.charinfo) or row.charinfo or {}
        local job = type(row.job) == 'string' and json.decode(row.job) or row.job or {}

        return {
            charId    = row.citizenid,
            firstName = charinfo.firstname,
            lastName  = charinfo.lastname,
            dob       = charinfo.birthdate,
            gender    = (charinfo.gender == 1 or charinfo.gender == 'female') and 1 or 0,
            stateId   = row.citizenid,
            job       = { name = job.name, label = job.label, grade = job.grade and job.grade.name, gradeLabel = job.grade and job.grade.name, rank = job.grade and job.grade.level or 0 },
        }
    end,
})
