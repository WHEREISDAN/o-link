-- bcs-housing provider (BagusCodeStudio). Owned homes are listed via the
-- GetOwnedHomeKeys server export and entered via the Housing:client:EnterHome
-- event. bcs-housing has no documented free "grant a starter apartment" API
-- (apartments are acquired in-world), so CreateStartingApartment is unsupported
-- and new bcs-housing characters fall through to the multichar spawn selector.
--
-- NOTE: bcs-housing is a paid, partly-encrypted script; export/event names below
-- are from its public docs. Verify against your installed version.

if not olink._guardImpl('Housing', 'bcs-housing', 'bcs-housing') then return end

local RESOURCE = 'bcs-housing'
local function isStarted() return GetResourceState(RESOURCE) == 'started' end

local function getCitizenId(src)
    local ok, player = pcall(function() return exports['qb-core']:GetPlayer(src) end)
    if ok and player and player.PlayerData then return player.PlayerData.citizenid end
    return nil
end

-- Presence relay is handled by the generic o-link:server:OnPlayerInside event,
-- which the client bounces bcs's Housing:client:EnterHome / DeleteFurnitures into.

olink._register('housing', {
    GetResourceName = function() return RESOURCE end,

    GetOwnedProperties = function(src, identifier)
        if not isStarted() then return {} end
        local cid = identifier or getCitizenId(src)
        if not cid then return {} end

        local ok, keys = pcall(function() return exports['bcs_housing']:GetOwnedHomeKeys(cid) end)
        if not ok or type(keys) ~= 'table' then return {} end

        local out = {}
        for _, k in ipairs(keys) do
            -- keys may be ids or {id,label} tables depending on bcs version.
            local id = type(k) == 'table' and (k.id or k.home or k.key) or k
            local label = type(k) == 'table' and (k.label or k.name) or ('Home ' .. tostring(id))
            if id ~= nil then
                out[#out + 1] = { id = id, kind = 'house', label = label }
            end
        end
        return out
    end,

    -- No documented free-grant API in bcs-housing; new characters use the selector.
    CreateStartingApartment = function() return false end,

    SpawnInside = function(src, id)
        if not isStarted() or id == nil then return false end
        TriggerClientEvent('o-link:housing:bcs:enter', src, id)
        return true
    end,
})
