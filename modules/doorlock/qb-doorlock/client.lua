if not olink._guardImpl('Doorlock', 'qb-doorlock', 'qb-doorlock') then return end

olink._register('doorlock', {
    ---@return string | nil
    GetClosestDoor = function()
        local ped = PlayerPedId()
        -- Not all qb-doorlock versions ship this export; fall back to scanning.
        local ok, closestDoor = pcall(function() return exports['qb-doorlock']:GetClosestDoor() end)
        if ok and closestDoor ~= nil and (type(closestDoor) ~= 'table' or next(closestDoor)) then
            return closestDoor
        end
        local allDoors = exports['qb-doorlock']:GetDoorList()
        local pedCoords = GetEntityCoords(ped)
        local door = 0
        local doorDist = 1000.0
        for doorID, data in pairs(allDoors) do
            if data.objCoords then
                local dist = #(pedCoords - data.objCoords)
                if dist < doorDist then
                    door = doorID
                    doorDist = dist
                end
            end
        end
        return door
    end,

    ---@return string
    GetResourceName = function()
        return 'qb-doorlock'
    end,
})
