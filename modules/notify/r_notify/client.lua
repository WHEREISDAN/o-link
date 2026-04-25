if not olink._guardNotifyAdapter('r_notify', 'r_notify') then return end

local mod = {
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    ---@param title string|nil
    Send = function(message, notifType, duration, title)
        duration = duration or 3000
        exports.r_notify:notify({
            title    = title or 'Notification',
            content  = message,
            type     = notifType or 'success',
            icon     = 'fas fa-check',
            duration = duration,
            position = 'top-right',
            sound    = false,
        })
    end,
}

olink._register('notify', mod, 'r_notify')
