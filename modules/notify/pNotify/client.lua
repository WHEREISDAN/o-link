if not olink._guardNotifyAdapter('pNotify', 'pNotify') then return end

local mod = {
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    ---@param title string|nil
    Send = function(message, notifType, duration, title)
        duration = duration or 3000
        local payload = { text = message, type = notifType or 'success', timeout = duration, layout = 'centerRight' }
        if title then payload.title = title end
        exports['pNotify']:SendNotification(payload)
    end,
}

olink._register('notify', mod, 'pNotify')
