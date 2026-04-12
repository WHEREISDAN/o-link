if GetResourceState('qb-core') ~= 'started' then return end
if GetResourceState('qbx_core') == 'started' then return end

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function(src)
    src = src or source
    TriggerEvent('olink:server:playerReady', src)
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(src)
    src = src or source
    TriggerEvent('olink:server:playerUnload', src)
end)

AddEventHandler('playerDropped', function()
    local src = source
    TriggerEvent('olink:server:playerUnload', src)
    TriggerEvent('olink:server:playerDropped', src)
end)

return true
