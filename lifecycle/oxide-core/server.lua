if GetResourceState('oxide-core') ~= 'started' then return end

AddEventHandler('oxide:core:playerReady', function(src)
    TriggerEvent('olink:server:playerReady', src)
end)

AddEventHandler('oxide:core:characterUnloaded', function(src)
    TriggerEvent('olink:server:playerUnload', src)
end)

AddEventHandler('playerDropped', function()
    local src = source
    TriggerEvent('olink:server:playerUnload', src)
    TriggerEvent('olink:server:playerDropped', src)
end)

return true
