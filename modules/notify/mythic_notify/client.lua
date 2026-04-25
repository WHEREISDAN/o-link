if not olink._guardNotifyAdapter('mythic_notify', 'mythic_notify') then return end

local mod = {
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    ---@param title string|nil unused (mythic_notify has no title support)
    Send = function(message, notifType, duration, title)
        duration = duration or 3000
        exports['mythic_notify']:SendAlert(notifType or 'inform', message, duration)
    end,
}

olink._register('notify', mod, 'mythic_notify')
