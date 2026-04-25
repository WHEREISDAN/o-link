if not olink._guardNotifyAdapter('okokNotify', 'okokNotify') then return end

local mod = {
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    ---@param title string|nil
    Send = function(message, notifType, duration, title)
        duration = duration or 3000
        exports['okokNotify']:Alert(title or 'Notification', message, duration, notifType or 'Success', false)
    end,
}

olink._register('notify', mod, 'okokNotify')
