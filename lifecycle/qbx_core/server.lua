if GetResourceState('qbx_core') == 'missing' then return end

-- QBX Core fires the same server-side events as QBCore
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
