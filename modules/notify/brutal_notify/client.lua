if not olink._guardImpl('Notify', 'brutal_notify', 'brutal_notify') then return end

local mod = {
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    ---@param title string|nil
    Send = function(message, notifType, duration, title)
        duration = duration or 3000
        exports['brutal_notify']:SendAlert(title or 'Notification', message, duration, notifType or 'success', false)
    end,
}

RegisterNetEvent('o-link:client:notify', function(message, notifType, duration, title)
    mod.Send(message, notifType, duration, title)
end)

olink._register('notify', mod, 'brutal_notify')
