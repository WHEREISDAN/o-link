if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:playerLoaded', function()
    Wait(1500)
    TriggerEvent('olink:client:playerReady')
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    TriggerEvent('olink:client:playerUnload')
end)

RegisterNetEvent('esx:setJob', function(jobData)
    TriggerEvent('olink:client:jobChanged', jobData)
end)

-- Handle resource restart: if player is already loaded, fire the ready event
CreateThread(function()
    Wait(1000)
    if ESX.IsPlayerLoaded() then
        TriggerEvent('olink:client:playerReady')
    end
end)

return true
