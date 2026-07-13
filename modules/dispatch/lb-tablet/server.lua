if not olink._guardImpl('Dispatch', 'lb-tablet', 'lb-tablet') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'lb-tablet'
    end,
})

local lastAlert = {}

RegisterNetEvent('o-link:dispatch:lb-tablet:sendAlert', function(data)
    local src = source
    if not src or src == 0 or type(data) ~= 'table' then return end

    local now = GetGameTimer()
    if lastAlert[src] and (now - lastAlert[src]) < 5000 then return end
    lastAlert[src] = now

    -- Server-authoritative location: never trust client-supplied coords.
    local ped = GetPlayerPed(src)
    if ped and ped > 0 then
        local coords = GetEntityCoords(ped)
        data.location = type(data.location) == 'table' and data.location or {}
        data.location.coords = vec2(coords.x, coords.y)
    end

    if GetResourceState('lb-tablet') ~= 'started' then return end
    pcall(function() exports['lb-tablet']:AddDispatch(data) end)
end)

AddEventHandler('playerDropped', function()
    lastAlert[source] = nil
end)
