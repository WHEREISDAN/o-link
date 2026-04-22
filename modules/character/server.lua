-- Cross-framework character helpers built on top of the registered adapter.
-- Loads after per-framework character adapters due to alphabetical glob order.

if olink._characterHelpersLoaded then return end
olink._characterHelpersLoaded = true

olink._register('character', {
    ---Convenience wrapper: returns the player's date-of-birth string, if any.
    ---Mirrors community_bridge's `GetPlayerDob(src)`.
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
    ---as the given identifier. Mirrors community_bridge's
    ---`Framework.GetAccountCharacterIdentifiers(identifier)`.
    ---
    ---On ESX the identifier IS the license, so only that identifier is returned.
    ---On QB/QBX we look up the license column and return every citizenid
    ---associated with it.
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
