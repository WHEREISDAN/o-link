-- Cross-framework character helpers built on top of the registered adapter.
-- Loads after per-framework character adapters due to alphabetical glob order.

if olink._characterHelpersLoaded then return end
olink._characterHelpersLoaded = true

-- ============================================================================
-- Shared character-search helpers
-- ----------------------------------------------------------------------------
-- Used by every character adapter's Search() implementation. The pattern is:
--   1. SQL fetches a bounded set of candidate rows (no JSON predicates, no
--      LIKE on framework-specific columns — let the DB do indexed paging only)
--   2. Adapter extracts firstname/lastname/charId from each row in its own
--      framework-specific way
--   3. This helper does the actual normalize-and-compare in Lua
--
-- Why Lua, not SQL: MySQL/MariaDB JSON-derived strings carry inherited
-- collations that vary across versions (utf8mb4_bin on older builds, default
-- collation on newer ones). `LIKE` against those is case-sensitive on some
-- customer environments and case-insensitive on others — non-portable. Doing
-- the match in Lua against already-normalized strings is byte-exact and
-- deterministic everywhere. Also tolerates whitespace contamination (NBSP,
-- trailing spaces) that breaks SQL CONCAT-based matching.
-- ============================================================================

olink._character = olink._character or {}

---Normalize a string for search comparison: trim leading/trailing whitespace
---(including non-breaking space U+00A0), collapse internal whitespace runs to
---a single space, lowercase.
---@param s any
---@return string
function olink._character.normalizeSearch(s)
    if type(s) ~= 'string' then return '' end
    -- Trim leading/trailing ASCII whitespace + UTF-8 NBSP (0xC2 0xA0)
    s = s:gsub('^[%s\194\160]+', ''):gsub('[%s\194\160]+$', '')
    -- Collapse internal whitespace + NBSP runs to single ASCII space
    s = s:gsub('[%s\194\160]+', ' ')
    return s:lower()
end

---Check whether a candidate matches the needle. Compares first name, last
---name, "first last", "last first", and the char identifier. Caller passes
---already-extracted strings — this helper doesn't know about JSON or row
---shapes.
---@param needle string Already normalized via normalizeSearch
---@param firstname string|nil
---@param lastname string|nil
---@param charId string|number|nil
---@param extras string[]|nil Additional fields to substring-match (e.g. phone, ssn)
---@return boolean
function olink._character.matchesSearch(needle, firstname, lastname, charId, extras)
    if not needle or needle == '' then return false end

    local first = olink._character.normalizeSearch(firstname)
    local last  = olink._character.normalizeSearch(lastname)

    if first ~= '' and first:find(needle, 1, true) then return true end
    if last  ~= '' and last:find(needle, 1, true)  then return true end

    if first ~= '' and last ~= '' then
        if (first .. ' ' .. last):find(needle, 1, true) then return true end
        if (last  .. ' ' .. first):find(needle, 1, true) then return true end
    end

    if charId then
        local id = tostring(charId):lower()
        if id:find(needle, 1, true) then return true end
    end

    if extras then
        for _, extra in ipairs(extras) do
            local norm = olink._character.normalizeSearch(extra)
            if norm ~= '' and norm:find(needle, 1, true) then return true end
        end
    end

    return false
end

-- Safety cap on the SQL fetch. Bound so a runaway query can't pull 100k rows
-- into Lua, but high enough that any realistic RP server's character roster
-- fits in one fetch. If you outgrow this, add a generated/indexed search
-- column on the players table instead of raising this cap.
olink._character.SEARCH_FETCH_CAP = 5000

olink._register('character', {
    ---Returns the player's date-of-birth string, if any.
    ---@param src number
    ---@return string|nil
    GetDob = function(src)
        if not olink.character then return nil end
        local id = olink.character.GetIdentifier and olink.character.GetIdentifier(src) or nil
        if not id then return nil end
        local offline = olink.character.GetOffline and olink.character.GetOffline(id) or nil
        return offline and offline.dob or nil
    end,

    ---Return all character identifiers on the same account (same game license)
    ---as the given identifier. On ESX the identifier IS the license, so only that
    ---identifier is returned. On QB/QBX, returns every citizenid sharing the license.
    ---@param identifier string
    ---@return string[]
    GetAccountCharacterIdentifiers = function(identifier)
        if not identifier then return {} end
        local fw = olink.framework and olink.framework.GetName and olink.framework.GetName() or nil

        if fw == 'es_extended' then
            return { identifier }
        end

        -- QB-style: players table has a `license` column; citizenid shares an account.
        local row = MySQL.single.await('SELECT license FROM players WHERE citizenid = ?', { identifier })
        if not row or not row.license then return { identifier } end

        local rows = MySQL.query.await('SELECT citizenid FROM players WHERE license = ?', { row.license })
        if not rows then return { identifier } end

        local out = {}
        for _, r in ipairs(rows) do
            out[#out + 1] = r.citizenid
        end
        return out
    end,
})
