if not olink._guardImpl('Character', 'oxide-core', 'oxide-core') then return end

local Oxide = exports['oxide-core']:Core()

---@param src number
---@return table|nil character
local function GetChar(src)
    local player = Oxide.Functions.GetPlayer(src)
    if not player then return nil end
    return player.GetCharacter()
end

olink._register('character', {
    ---@param src number
    ---@return string|nil
    GetIdentifier = function(src)
        local char = GetChar(src)
        if not char then return nil end
        return tostring(char.stateId)
    end,

    ---@param src number
    ---@return string|nil firstName, string|nil lastName
    GetName = function(src)
        local char = GetChar(src)
        if not char then return nil, nil end
        return char.firstName, char.lastName
    end,

    ---@param src number
    ---@param key string
    ---@return any|nil
    GetMetadata = function(src, key)
        local char = GetChar(src)
        if not char then return nil end
        return char.GetMetadata(key)
    end,

    ---@param src number
    ---@param key string
    ---@param value any
    ---@return boolean
    SetMetadata = function(src, key, value)
        local char = GetChar(src)
        if not char then return false end
        char.SetMetadata(key, value)
        return true
    end,

    ---@param src number
    ---@return table|nil
    GetAllMetadata = function(src)
        local char = GetChar(src)
        if not char then return nil end
        return char.GetMetadata()
    end,

    ---@param src number
    ---@param isBoss boolean
    ---@return boolean
    SetBoss = function(src, isBoss)
        local char = GetChar(src)
        if not char then return false end
        char.SetBoss(isBoss)
        return true
    end,

    ---@param src number
    ---@return boolean
    IsBoss = function(src)
        local char = GetChar(src)
        if not char then return false end
        return char.IsBoss()
    end,

    ---Search characters by state_id (prefix), first/last name, or full name in
    ---either "first last" or "last first" order. Multi-word queries match
    ---against the concatenated name; LIKE wildcards in user input are escaped.
    ---@param query string
    ---@param limit number|nil Max results (default 20)
    ---@return table[] CharacterData[]
    Search = function(query, limit)
        limit = limit or 20
        local q = type(query) == 'string' and query:match('^%s*(.-)%s*$') or ''
        if #q < 2 then return {} end

        local escaped = q:gsub('\\', '\\\\'):gsub('([%%_])', '\\%1')
        local like    = '%' .. escaped .. '%'
        local prefix  = escaped .. '%'

        local results = MySQL.query.await([[
            SELECT char_id, first_name, last_name, date_of_birth, gender, state_id, job, last_played
            FROM characters
            WHERE deleted_at IS NULL
              AND (
                    state_id LIKE ?
                 OR first_name LIKE ?
                 OR last_name LIKE ?
                 OR CONCAT(first_name, ' ', last_name) LIKE ?
                 OR CONCAT(last_name, ' ', first_name) LIKE ?
              )
            ORDER BY last_played IS NULL, last_played DESC
            LIMIT ?
        ]], { prefix, like, like, like, like, limit })

        if not results then return {} end

        for i, row in ipairs(results) do
            local job = row.job
            if type(job) == 'string' then job = json.decode(job) or {} end
            results[i] = {
                charId    = tostring(row.state_id),
                firstName = row.first_name,
                lastName  = row.last_name,
                dob       = row.date_of_birth,
                gender    = row.gender,
                stateId   = row.state_id,
                job       = job and { name = job.jobName, label = job.jobLabel, grade = job.gradeName, gradeLabel = job.gradeLabel, rank = job.gradeRank } or nil,
            }
        end

        return results
    end,

    ---@param identifier string state_id (or char_id for backwards compat)
    ---@return table|nil CharacterData
    GetOffline = function(identifier)
        -- Try state_id first, fall back to char_id if numeric
        local row = MySQL.single.await([[
            SELECT char_id, first_name, last_name, date_of_birth, gender, state_id, job
            FROM characters
            WHERE state_id = ? AND deleted_at IS NULL
        ]], { identifier })

        if not row and tonumber(identifier) then
            row = MySQL.single.await([[
                SELECT char_id, first_name, last_name, date_of_birth, gender, state_id, job
                FROM characters
                WHERE char_id = ? AND deleted_at IS NULL
            ]], { tonumber(identifier) })
        end

        if not row then return nil end

        local job = row.job
        if type(job) == 'string' then job = json.decode(job) or {} end

        return {
            charId    = tostring(row.state_id),
            firstName = row.first_name,
            lastName  = row.last_name,
            dob       = row.date_of_birth,
            gender    = row.gender,
            stateId   = row.state_id,
            job       = job and { name = job.jobName, label = job.jobLabel, grade = job.gradeName, gradeLabel = job.gradeLabel, rank = job.gradeRank } or nil,
        }
    end,
})
