if not olink._guardNotifyAdapter('wasabi_notify', 'wasabi_notify') then return end

local mod = {
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    ---@param title string|nil unused (wasabi_notify doesn't render titles)
    Send = function(message, notifType, duration, title)
        duration = duration or 3000
        notifType = notifType or 'info'
        exports.wasabi_notify:notify(notifType, message, duration, notifType)
    end,
}

olink._register('notify', mod, 'wasabi_notify')
