if not olink._guardImpl('Framework', 'es_extended', 'es_extended') then return end

-- These events originate server-side from es_extended via TriggerEvent (src as
-- arg). AddEventHandler keeps them off the network so clients can't spoof them.
AddEventHandler('esx:playerLoaded', function(src)
    src = tonumber(src)
    if not src then return end
    TriggerEvent('olink:server:playerReady', src)
end)

-- esx:playerLogout fires before the player drops; also handle playerDropped for clean disconnect
AddEventHandler('esx:playerLogout', function(src)
    src = tonumber(src)
    if not src then return end
    TriggerEvent('olink:server:playerUnload', src)
end)

AddEventHandler('esx:setJob', function(src, jobData)
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
