local RESOURCE = 'qbx_properties'

if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Housing', RESOURCE, false) then return end

-- Bounce: server adapter -> here -> the native client->server enter event (so
-- the player's source is set correctly for qbx_properties' access check).
RegisterNetEvent('o-link:housing:qbx:enter', function(data)
    TriggerServerEvent('qbx_properties:server:enterProperty', data)
end)

olink._register('housing', {
    GetResourceName = function() return RESOURCE end,
})
