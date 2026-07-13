if not olink._guardImpl('Dispatch', 'redutzu-mdt', 'redutzu-mdt') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'redutzu-mdt'
    end,
})

local lastAlert = {}

RegisterNetEvent('o-link:dispatch:redutzu-mdt:sendAlert', function(data)
    local src = source
    if not src or src == 0 or type(data) ~= 'table' then return end

    local now = GetGameTimer()
    if lastAlert[src] and (now - lastAlert[src]) < 5000 then return end
    lastAlert[src] = now

    -- Server-authoritative location: never trust client-supplied coords.
    local ped = GetPlayerPed(src)
    local coords = (ped and ped > 0) and GetEntityCoords(ped) or nil
    if not coords then return end

    TriggerEvent('redutzu-mdt:server:addDispatchToMDT', {
        code = tostring(data.code or '10-80'),
        title = tostring(data.message or 'Dispatch Alert'),
        street = tostring(data.street or 'Unknown'),
        duration = tonumber(data.time) or 10000,
        coords = coords,
    })
end)

AddEventHandler('playerDropped', function()
    lastAlert[source] = nil
end)
