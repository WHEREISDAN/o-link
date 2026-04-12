if GetResourceState('doors_creator') == 'missing' then return end

olink._register('doorlock', {
    ---@param doorID string
    ---@param toggle boolean
    ---@return boolean
    ToggleDoorLock = function(doorID, toggle)
        local state = toggle
        if state then
            exports["doors_creator"]:setDoorState(doorID, 1)
        else
            exports["doors_creator"]:setDoorState(doorID, 0)
        end
        return true
    end,

    ---@return string
    GetResourceName = function()
        return 'doors_creator'
    end,
})
