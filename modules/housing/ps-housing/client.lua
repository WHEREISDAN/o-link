if not olink._guardImpl('Housing', 'ps-housing', 'ps-housing') then return end

-- Bounce: the server adapter routes through here so the native ps-housing events
-- run with the player's `source`. createNewApartment expects the apartment label;
-- enterProperty expects the property id.
RegisterNetEvent('o-link:housing:ps:create', function(label)
    TriggerServerEvent('ps-housing:server:createNewApartment', label)
end)

RegisterNetEvent('o-link:housing:ps:enter', function(id)
    TriggerServerEvent('ps-housing:server:enterProperty', id)
end)

olink._register('housing', {
    GetResourceName = function() return 'ps-housing' end,
})
