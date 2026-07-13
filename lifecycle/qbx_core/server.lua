if not olink._guardImpl('Framework', 'qbx_core', 'qbx_core') then return end

-- qbx_core (client/character.lua) and qbx_spawn fire this from the CLIENT via
-- TriggerServerEvent with no args, so it must stay net-registered — but the
-- sender can only announce themselves: any client-supplied src arg is ignored
-- (that was the impersonation vector), and the relay only fires once qbx_core
-- actually has the player loaded.
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function(src)
    local netSrc = source
    src = (netSrc and netSrc > 0) and netSrc or tonumber(src)
    if not src then return end
    if not exports.qbx_core:GetPlayer(src) then return end
    TriggerEvent('olink:server:playerReady', src)
end)

-- OnPlayerUnload / OnJobUpdate originate server-side from qbx_core via
-- TriggerEvent (src as arg). AddEventHandler keeps them off the network so
-- clients can't spoof them.
AddEventHandler('QBCore:Server:OnPlayerUnload', function(src)
    src = tonumber(src)
    if not src then return end
    TriggerEvent('olink:server:playerUnload', src)
end)

AddEventHandler('QBCore:Server:OnJobUpdate', function(src, jobData)
    src = tonumber(src)
    if not src then return end
    if jobData and jobData.name then
        TriggerEvent('olink:server:jobChanged', src, jobData.name)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    TriggerEvent('olink:server:playerUnload', src)
    TriggerEvent('olink:server:playerDropped', src)
end)

return true
