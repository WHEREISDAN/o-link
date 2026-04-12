if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

---@param src number
---@return table|nil xPlayer
local function GetPlayer(src)
    return ESX.GetPlayerFromId(src)
end

olink._register('character', {
    ---@param src number
    ---@return string|nil
    GetIdentifier = function(src)
        local xPlayer = GetPlayer(src)
        if not xPlayer then return nil end
        return xPlayer.getIdentifier()
    end,

    ---@param src number
    ---@return string|nil firstName, string|nil lastName
    GetName = function(src)
        local xPlayer = GetPlayer(src)
        if not xPlayer then return nil, nil end
        return xPlayer.variables.firstName, xPlayer.variables.lastName
    end,

    ---@param src number
    ---@param key string
    ---@return any|nil
    GetMetadata = function(src, key)
        local xPlayer = GetPlayer(src)
        if not xPlayer then return nil end
        return xPlayer.getMeta(key)
    end,

    ---@param src number
    ---@param key string
    ---@param value any
    ---@return boolean
    SetMetadata = function(src, key, value)
        local xPlayer = GetPlayer(src)
        if not xPlayer then return false end
        xPlayer.setMeta(key, value)
        return true
    end,

    ---@param src number
    ---@return table|nil
    GetAllMetadata = function(src)
        local xPlayer = GetPlayer(src)
        if not xPlayer then return nil end
        return xPlayer.getMeta()
    end,

    ---@param src number
    ---@param isBoss boolean
    ---@return boolean
    -- ESX has no native boss concept — stored in metadata as fallback
    SetBoss = function(src, isBoss)
        local xPlayer = GetPlayer(src)
        if not xPlayer then return false end
        xPlayer.setMeta('isBoss', isBoss)
        return true
    end,

    ---@param src number
    ---@return boolean
    -- ESX has no native boss concept — reads from metadata fallback
    IsBoss = function(src)
        local xPlayer = GetPlayer(src)
        if not xPlayer then return false end
        return xPlayer.getMeta('isBoss') == true
    end,

    ---@param query string
    ---@param limit number|nil
    ---@return table[]
    Search = function(query, limit)
        limit = limit or 20
        if not query or #query < 2 then return {} end

        local rows = MySQL.query.await([[
            SELECT identifier, firstname, lastname, dateofbirth, sex, job, job_grade
            FROM users
            WHERE firstname LIKE ? OR lastname LIKE ? OR identifier = ?
            LIMIT ?
        ]], { '%' .. query .. '%', '%' .. query .. '%', query, limit })

        if not rows then return {} end

        local results = {}
        for _, row in ipairs(rows) do
            results[#results + 1] = {
                charId    = row.identifier,
                firstName = row.firstname,
                lastName  = row.lastname,
                dob       = row.dateofbirth,
                gender    = row.sex == 'f' and 1 or 0,
                stateId   = row.identifier,
                job       = { name = row.job or 'unemployed', label = row.job or 'Unemployed', grade = tostring(row.job_grade or 0), gradeLabel = tostring(row.job_grade or 0), rank = row.job_grade or 0 },
            }
        end
        return results
    end,

    ---@param charId string identifier
    ---@return table|nil
    GetOffline = function(charId)
        local row = MySQL.single.await([[
            SELECT identifier, firstname, lastname, dateofbirth, sex, job, job_grade
            FROM users WHERE identifier = ?
        ]], { charId })

        if not row then return nil end

        return {
            charId    = row.identifier,
            firstName = row.firstname,
            lastName  = row.lastname,
            dob       = row.dateofbirth,
            gender    = row.sex == 'f' and 1 or 0,
            stateId   = row.identifier,
            job       = { name = row.job or 'unemployed', label = row.job or 'Unemployed', grade = tostring(row.job_grade or 0), gradeLabel = tostring(row.job_grade or 0), rank = row.job_grade or 0 },
        }
    end,
})
