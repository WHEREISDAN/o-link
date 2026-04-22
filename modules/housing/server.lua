-- Housing integration relay.
-- Mirrors community_bridge's _OnPlayerInside: adapters fire the internal
-- `o-link:server:OnPlayerInside` event (with src + insideId from a server
-- TriggerEvent, or just insideId from a client TriggerServerEvent); this
-- relay enriches with the routing bucket + player coords and re-emits a
-- public event resources can listen to.

if olink._housingRelayLoaded then return end
olink._housingRelayLoaded = true

local function relay(src, insideId)
    if not src or src == 0 then return end
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end

    TriggerEvent('o-link:server:housing:onPlayerInside',
        src,
        insideId,
        GetPlayerRoutingBucket(src),
        GetEntityCoords(ped))
end

RegisterNetEvent('o-link:server:OnPlayerInside', function(arg1, arg2)
    -- Client-triggered: `source` is the player, first arg is insideId.
    -- Server-triggered: `source` is 0, args are (src, insideId).
    local src, insideId
    if source and source ~= 0 then
        src, insideId = source, arg1
    else
        src, insideId = arg1, arg2
    end
    relay(src, insideId)
end)
