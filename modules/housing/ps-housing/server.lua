-- ps-housing provider (Project Sloth). Apartments and houses share the
-- `properties` table; a row is an apartment when its `apartment` column is set.
-- Coordinates live inside JSON columns (door_data/zone_data) and are not reliably
-- decodable here, so listed properties are list-only (no world marker).
--
-- NOTE: ps-housing event/column names below are from its public source/docs
-- (Project-Sloth/ps-housing). Verify against your installed version if customised.

if not olink._guardImpl('Housing', 'ps-housing', 'ps-housing') then return end

local RESOURCE = 'ps-housing'
local function isStarted() return GetResourceState(RESOURCE) == 'started' end

-- ps-housing's free starter apartments. The labels are what
-- `ps-housing:server:createNewApartment` expects. Mirrors ps-housing's apartment
-- list; adjust if you customise ps-housing's apartments.
local STARTER_APARTMENTS = {
    'South Rockford Drive', 'Morningwood Blvd', 'Integrity Way',
    'Tinsel Towers', 'Fantastic Plaza', 'Modern 1 Apartment',
}

local function getCitizenId(src)
    local ok, player = pcall(function() return exports['qb-core']:GetPlayer(src) end)
    if ok and player and player.PlayerData then return player.PlayerData.citizenid end
    return nil
end

-- Presence relay: o-link piggybacks on ps-housing's own enter/leave events so the
-- inside-tracking relay fires regardless of who triggered the spawn.
RegisterNetEvent('ps-housing:server:enterProperty', function(insideId)
    TriggerEvent('o-link:server:OnPlayerInside', source, insideId)
end)
RegisterNetEvent('ps-housing:server:leaveProperty', function(insideId)
    TriggerEvent('o-link:server:OnPlayerInside', source, insideId)
end)

olink._register('housing', {
    GetResourceName = function() return RESOURCE end,

    GetOwnedProperties = function(src, identifier)
        if not isStarted() then return {} end
        local cid = identifier or getCitizenId(src)
        if not cid then return {} end
        local rows = MySQL.query.await(
            'SELECT property_id, apartment, street FROM properties WHERE owner_citizenid = ?', { cid }) or {}
        local out = {}
        for _, p in ipairs(rows) do
            out[#out + 1] = {
                id = p.property_id,
                kind = p.apartment and 'apartment' or 'house',
                label = p.apartment or p.street or ('Property ' .. tostring(p.property_id)),
            }
        end
        return out
    end,

    -- Selectable starter apartments for the multichar picker. ps-housing apartments
    -- are instanced shells with no fixed world entrance, so these are list-only.
    ListStarterApartments = function()
        if not isStarted() then return {} end
        local out = {}
        for _, label in ipairs(STARTER_APARTMENTS) do
            out[#out + 1] = { key = label, label = label }
        end
        return out
    end,

    -- def.label = the apartment label `ps-housing:server:createNewApartment` expects.
    -- That event uses the caller's `source`, so we bounce through the client.
    -- ps-housing creates the apartment and spawns the player inside.
    CreateStartingApartment = function(src, def)
        if not isStarted() then return false end
        local cid = getCitizenId(src)
        if not cid then return false end

        -- Already owns an apartment: enter it rather than create a duplicate.
        local existing = MySQL.single.await(
            'SELECT property_id, apartment FROM properties WHERE owner_citizenid = ? AND apartment IS NOT NULL', { cid })
        if existing then
            TriggerClientEvent('o-link:housing:ps:enter', src, existing.property_id)
            return { id = existing.property_id, label = existing.apartment }
        end

        local label = (type(def) == 'table' and def.label) or STARTER_APARTMENTS[1]
        TriggerClientEvent('o-link:housing:ps:create', src, label)
        return { id = label, label = label }
    end,

    SpawnInside = function(src, id)
        if not isStarted() or not id then return false end
        TriggerClientEvent('o-link:housing:ps:enter', src, id)
        return true
    end,
})
