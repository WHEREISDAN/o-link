if GetResourceState('qb-doorlock') == 'missing' then return end

olink._register('doorlock', {
    ---@param doorID string
    ---@param toggle boolean
    ---@return boolean
    ToggleDoorLock = function(doorID, toggle)
        TriggerClientEvent('qb-doorlock:client:setState', -1, 0, doorID, toggle, false, false, false)
        return true
    end,

    ---@return string
    GetResourceName = function()
        return 'qb-doorlock'
    end,
})
