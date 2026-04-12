if GetResourceState('rcore_doorlock') == 'missing' then return end

olink._register('doorlock', {
    ---@return string | nil
    GetClosestDoor = function()
        local ped = PlayerPedId()
        local allDoors = exports.rcore_doorlock:getLoadedDoors()
        local pedCoords = GetEntityCoords(ped)
        local door = 0
        local doorDist = 1000.0
        for _, data in pairs(allDoors) do
            local dist = #(pedCoords - data.coords)
            if dist < doorDist then
                door = data.id
                doorDist = dist
            end
        end
        return door
    end,

    ---@return string
    GetResourceName = function()
        return 'rcore_doorlock'
    end,
})
