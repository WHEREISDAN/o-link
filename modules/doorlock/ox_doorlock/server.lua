if GetResourceState('ox_doorlock') == 'missing' then return end

olink._register('doorlock', {
    ---@param doorID string|number
    ---@param toggle boolean
    ---@return boolean
    ToggleDoorLock = function(doorID, toggle)
        if type(doorID) == 'string' then
            doorID = tonumber(doorID)
        end
        local state = toggle
        if state then
            exports.ox_doorlock:setDoorState(doorID, 1)
        else
            exports.ox_doorlock:setDoorState(doorID, 0)
        end
        return true
    end,

    ---@return string
    GetResourceName = function()
        return 'ox_doorlock'
    end,
})
