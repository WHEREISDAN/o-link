if not olink._guardImpl('Housing', 'bcs-housing', 'bcs-housing') then return end

RegisterNetEvent('Housing:client:EnterHome', function(insideId)
    TriggerServerEvent('o-link:server:OnPlayerInside', insideId)
end)

RegisterNetEvent("Housing:client:DeleteFurnitures", function()
    TriggerServerEvent('o-link:server:OnPlayerInside', false)
end)

-- Bounce: server SpawnInside -> here -> bcs's own EnterHome handler (entering an
-- owned home from the spawn selector). Re-firing the event locally invokes
-- bcs-housing's registered handler to perform the teleport.
RegisterNetEvent('o-link:housing:bcs:enter', function(id)
    TriggerEvent('Housing:client:EnterHome', id)
end)

olink._register('housing', {
    GetResourceName = function() return 'bcs-housing' end,
})
