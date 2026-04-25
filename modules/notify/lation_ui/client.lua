if not olink._guardNotifyAdapter('lation_ui', 'lation_ui') then return end

local mod = {
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    ---@param title string|nil
    Send = function(message, notifType, duration, title)
        duration = duration or 3000
        local payload = { message = message, type = notifType or 'success', duration = duration, position = 'top-right' }
        if title then payload.title = title end
        exports.lation_ui:notify(payload)
    end,
}

olink._register('notify', mod, 'lation_ui')
