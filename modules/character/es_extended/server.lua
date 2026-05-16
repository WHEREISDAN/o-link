if not olink._guardImpl('Character', 'es_extended', 'es_extended') then return end

local ESX = exports['es_extended']:getSharedObject()

---@param src number
---@return table|nil xPlayer
local function GetPlayer(src)
    return ESX.GetPlayerFromId(src)
end

-- ESX's clearMeta errors when key is unset and Config.EnableDebug is true.
-- Probe the metadata table directly (xPlayer.getMeta also errors under debug).
local function safeClearMeta(xPlayer, key)
    if not xPlayer.metadata or xPlayer.metadata[key] == nil then return end
    xPlayer.clearMeta(key)
end

-- Detect optional `users` columns. esx_identity adds firstname/lastname/
-- dateofbirth/sex; ESX Legacy ≥ 1.13.3 adds ssn. Cached after the first
-- successful probe so we don't hit information_schema on every search.
local columnCache
local function detectColumns()
    if columnCache then return columnCache end
    local rows = MySQL.query.await([[
        SELECT column_name AS name FROM information_schema.columns
        WHERE table_schema = DATABASE() AND table_name = 'users'
          AND column_name IN ('firstname', 'lastname', 'dateofbirth', 'sex', 'ssn')
    ]]) or {}
    local present = {}
    for _, row in ipairs(rows) do present[row.name or row.column_name] = true end
    columnCache = {
        hasIdentity = present.firstname and present.lastname,
        hasSsn      = present.ssn == true,
    }
    return columnCache
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
    -- Read xPlayer.metadata directly; xPlayer.getMeta errors on unset keys
    -- when Config.EnableDebug is true.
    GetMetadata = function(src, key)
        local xPlayer = GetPlayer(src)
        if not xPlayer or not xPlayer.metadata then return nil end
        return xPlayer.metadata[key]
    end,

    ---@param src number
    ---@param key string
    ---@param value any
    ---@return boolean
    -- ESX's setMeta only accepts number/string/table. Normalize booleans/nil
    -- so consumers can write `SetMetadata(src, 'ishandcuffed', true/false/nil)`
    -- portably across frameworks. Truthy checks on the read side still work.
    SetMetadata = function(src, key, value)
        local xPlayer = GetPlayer(src)
        if not xPlayer then return false end
        if value == nil or value == false then
            safeClearMeta(xPlayer, key)
        elseif value == true then
            xPlayer.setMeta(key, 1)
        else
            xPlayer.setMeta(key, value)
        end
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
    -- ESX has no native boss concept — stored in metadata as fallback.
    -- setMeta rejects booleans, so flag is stored as 1 (truthy) / cleared.
    SetBoss = function(src, isBoss)
        local xPlayer = GetPlayer(src)
        if not xPlayer then return false end
        if isBoss then
            xPlayer.setMeta('isBoss', 1)
        else
            safeClearMeta(xPlayer, 'isBoss')
        end
        return true
    end,

    ---@param src number
    ---@return boolean
    IsBoss = function(src)
        local xPlayer = GetPlayer(src)
        if not xPlayer or not xPlayer.metadata then return false end
        return xPlayer.metadata.isBoss and true or false
    end,

    ---Search users by identifier (exact), SSN (prefix), first/last name, or
    ---full name in either order. The firstname/lastname/dateofbirth/sex
    ---columns come from esx_identity; if it isn't installed, name search is
    ---disabled and only identifier/SSN lookups run. LIKE wildcards in user
    ---input are escaped.
    ---@param query string
    ---@param limit number|nil
    ---@return table[]
    Search = function(query, limit)
        limit = limit or 20
        local q = type(query) == 'string' and query:match('^%s*(.-)%s*$') or ''
        if #q < 2 then return {} end

        local cols = detectColumns()
        local escaped = q:gsub('\\', '\\\\'):gsub('([%%_])', '\\%1')
        local like    = '%' .. escaped .. '%'
        local prefix  = escaped .. '%'

        local select  = 'identifier, job, job_grade'
        if cols.hasIdentity then select = select .. ', firstname, lastname, dateofbirth, sex' end
        if cols.hasSsn      then select = select .. ', ssn' end

        local where, params = { 'identifier = ?' }, { q }
        if cols.hasSsn then
            where[#where + 1] = 'ssn LIKE ?'
            params[#params + 1] = prefix
        end
        if cols.hasIdentity then
            where[#where + 1] = 'firstname LIKE ?'
            where[#where + 1] = 'lastname LIKE ?'
            where[#where + 1] = "CONCAT(firstname, ' ', lastname) LIKE ?"
            where[#where + 1] = "CONCAT(lastname, ' ', firstname) LIKE ?"
            params[#params + 1] = like
            params[#params + 1] = like
            params[#params + 1] = like
            params[#params + 1] = like
        end
        params[#params + 1] = limit

        local rows = MySQL.query.await(
            ('SELECT %s FROM users WHERE %s LIMIT ?'):format(select, table.concat(where, ' OR ')),
            params
        )

        if not rows then return {} end

        local results = {}
        for _, row in ipairs(rows) do
            results[#results + 1] = {
                charId    = row.identifier,
                firstName = row.firstname,
                lastName  = row.lastname,
                dob       = row.dateofbirth,
                gender    = row.sex == 'f' and 1 or 0,
                stateId   = row.ssn or row.identifier,
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
