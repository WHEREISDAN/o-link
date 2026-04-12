if GetResourceState('qbx_core') == 'missing' then return end

-- QBX Core fires the same client-side events as QBCore
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(1500)
    TriggerEvent('olink:client:playerReady')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    TriggerEvent('olink:client:playerUnload')
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(jobData)
    TriggerEvent('olink:client:jobChanged', jobData)
end)

-- Handle resource restart: QBX uses isLoggedIn statebag
CreateThread(function()
    Wait(1000)
    if LocalPlayer.state.isLoggedIn then
        TriggerEvent('olink:client:playerReady')
    end
end)

return true
