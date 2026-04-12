if GetResourceState('qb-doorlock') ~= 'started' then return end

olink._register('doorlock', {
    ---@return string | nil
    GetClosestDoor = function()
        local ped = PlayerPedId()
        local closestDoor = exports["qb-doorlock"]:GetClosestDoor()
        if Table.CheckPopulated(closestDoor) then return closestDoor end
        local allDoors = exports["qb-doorlock"]:GetDoorList()
        local pedCoords = GetEntityCoords(ped)
        local door = 0
        local doorDist = 1000.0
        for doorID, data in pairs(allDoors) do
            local dist = #(pedCoords - data.objCoords)
            if dist < doorDist then
                door = doorID
                doorDist = dist
            end
        end
        return door
    end,

    ---@return string
    GetResourceName = function()
        return 'qb-doorlock'
    end,
})
