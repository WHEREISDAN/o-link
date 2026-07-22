if not olink._guardImpl('Framework', 'qb-core', 'qb-core') then return end
if not olink._hasOverride('Framework') and GetResourceState('qbx_core') == 'started' then return end

-- Stock qb-spawn / qb-multicharacter fire this from the CLIENT via
-- TriggerServerEvent with no args, so it must stay net-registered — but the
-- sender can only announce themselves: any client-supplied src arg is ignored
-- (that was the impersonation vector), and the relay only fires once qb-core
-- actually has the player loaded.
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function(src)
    local netSrc = source
    src = (netSrc and netSrc > 0) and netSrc or tonumber(src)
    if not src then return end
    if not exports['qb-core']:GetCoreObject().Functions.GetPlayer(src) then return end
    TriggerEvent('olink:server:playerReady', src)
end)

-- OnPlayerUnload / OnJobUpdate originate server-side from qb-core via
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

-- Fired by qb-core's native duty toggles AND by o-link's job.SetDuty (which
-- re-triggers it manually), so one hook covers both paths.
AddEventHandler('QBCore:Server:SetDuty', function(src, duty)
    src = tonumber(src)
    if not src then return end
    local job = olink.job and olink.job.Get and olink.job.Get(src)
    TriggerEvent('olink:server:dutyChanged', src, duty == true, job and job.name or nil)
end)

AddEventHandler('playerDropped', function()
    local src = source
    TriggerEvent('olink:server:playerUnload', src)
    TriggerEvent('olink:server:playerDropped', src)
end)

return true
