if not olink._guardImpl('Framework', 'oxide-core', 'oxide-core') then return end

AddEventHandler('oxide:core:playerReady', function(src)
    TriggerEvent('olink:server:playerReady', src)
end)

AddEventHandler('oxide:core:characterUnloaded', function(src)
    TriggerEvent('olink:server:playerUnload', src)
end)

AddEventHandler('oxide:core:jobChanged', function(src, charId, oldJob, newJob)
    if newJob and newJob.jobName then
        TriggerEvent('olink:server:jobChanged', src, newJob.jobName)
    end
end)

AddEventHandler('oxide:core:dutyChanged', function(src, charId, onDuty, jobName)
    if not src then return end
    TriggerEvent('olink:server:dutyChanged', src, onDuty == true, jobName)
end)

AddEventHandler('playerDropped', function()
    local src = source
    TriggerEvent('olink:server:playerUnload', src)
    TriggerEvent('olink:server:playerDropped', src)
end)

return true
