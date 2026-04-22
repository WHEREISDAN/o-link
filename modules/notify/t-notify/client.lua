if not olink._guardImpl('Notify', 't-notify', 't-notify') then return end
if not olink._hasOverride('Notify') and GetResourceState('oxide-notify') == 'started' then return end

local mod = {
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    ---@param title string|nil
    Send = function(message, notifType, duration, title)
        duration = duration or 3000
        local payload = { style = notifType or 'info', message = message, duration = duration }
        if title then payload.title = title end
        exports['t-notify']:Alert(payload)
    end,
}

RegisterNetEvent('o-link:client:notify', function(message, notifType, duration, title)
    mod.Send(message, notifType, duration, title)
end)

olink._register('notify', mod)
