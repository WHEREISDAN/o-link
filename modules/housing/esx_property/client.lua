local RESOURCE = 'esx_property'

if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Housing', RESOURCE, false) then return end

-- Bounce: server adapter -> here -> the native client->server enter event.
RegisterNetEvent('o-link:housing:esx:enter', function(id)
    TriggerServerEvent('esx_property:enter', id)
end)

olink._register('housing', {
    GetResourceName = function() return RESOURCE end,
})
