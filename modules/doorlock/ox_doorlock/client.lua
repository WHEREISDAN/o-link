if GetResourceState('ox_doorlock') == 'missing' then return end

olink._register('doorlock', {
    ---@return string | nil
    GetClosestDoor = function()
        local doorData = exports.ox_doorlock:getClosestDoor()
        if not doorData then return end
        return tostring(doorData.id) or nil
    end,

    ---@return string
    GetResourceName = function()
        return 'ox_doorlock'
    end,
})
