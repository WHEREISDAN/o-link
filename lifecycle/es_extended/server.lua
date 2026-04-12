if GetResourceState('es_extended') ~= 'started' then return end

RegisterNetEvent('esx:playerLoaded', function(src)
    src = src or source
    TriggerEvent('olink:server:playerReady', src)
end)

-- esx:playerLogout fires before the player drops; also handle playerDropped for clean disconnect
RegisterNetEvent('esx:playerLogout', function(src)
    src = src or source
    TriggerEvent('olink:server:playerUnload', src)
end)

AddEventHandler('playerDropped', function()
    local src = source
    TriggerEvent('olink:server:playerUnload', src)
    TriggerEvent('olink:server:playerDropped', src)
end)

return true
