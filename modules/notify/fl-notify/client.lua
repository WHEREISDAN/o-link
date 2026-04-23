if not olink._guardImpl('Notify', 'fl-notify', 'FL-Notify') then return end

local function typeToCode(notifType)
    if notifType == 'error' or notifType == 'info' then
        return 1
    elseif notifType == 'warning' or notifType == 'warn' then
        return 3
    end
    return 2 -- success / default
end

local mod = {
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    ---@param title string|nil
    Send = function(message, notifType, duration, title)
        duration = duration or 3000
        exports['FL-Notify']:Notify(title or 'Notification', '', message, duration, typeToCode(notifType), 0)
    end,
}

RegisterNetEvent('o-link:client:notify', function(message, notifType, duration, title)
    mod.Send(message, notifType, duration, title)
end)

olink._register('notify', mod, 'FL-Notify')
