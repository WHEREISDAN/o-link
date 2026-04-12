if GetResourceState('rcore_doorlock') == 'missing' then return end

olink._register('doorlock', {
    ---@param doorID string
    ---@param toggle boolean
    ---@return boolean
    ToggleDoorLock = function(doorID, toggle)
        local state = toggle
        if state then
            exports.rcore_doorlock:changeDoorState(doorID, 0)
        else
            exports.rcore_doorlock:changeDoorState(doorID, 1)
        end
        return true
    end,

    ---@return string
    GetResourceName = function()
        return 'rcore_doorlock'
    end,
})
