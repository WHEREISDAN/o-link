if GetResourceState('qbx_core') ~= 'started' then return end

local QBox = exports.qbx_core

---@param src number
---@return table|nil
local function GetPlayer(src)
    return QBox:GetPlayer(src)
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

    ---@param query string
    ---@param limit number|nil
    ---@return table[]
    Search = function(query, limit)
        limit = limit or 20
        if not query or #query < 2 then return {} end

        local rows = MySQL.query.await([[
            SELECT citizenid, charinfo, job FROM players
            WHERE JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')) LIKE ?
               OR JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname')) LIKE ?
               OR citizenid = ?
            LIMIT ?
        ]], { '%' .. query .. '%', '%' .. query .. '%', query, limit })

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
                gender    = charinfo.gender == 'male' and 0 or 1,
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
            gender    = charinfo.gender == 'male' and 0 or 1,
            stateId   = row.citizenid,
            job       = { name = job.name, label = job.label, grade = job.grade and job.grade.name, gradeLabel = job.grade and job.grade.name, rank = job.grade and job.grade.level or 0 },
        }
    end,
})
