if not olink._guardNotifyAdapter('oxide-notify', 'oxide-notify') then return end

local mod = {
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    ---@param title string|nil
    ---@param props table|nil extra oxide-notify props
    Send = function(message, notifType, duration, title, props)
        local payload = {
            title = title,
            message = message,
            type = notifType,
            duration = duration,
        }
        if props then
            for k, v in pairs(props) do payload[k] = v end
        end
        exports['oxide-notify']:Notify(payload)
    end,
}

olink._register('notify', mod, 'oxide-notify')
