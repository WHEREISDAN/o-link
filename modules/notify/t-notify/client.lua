if GetResourceState('oxide-notify') == 'started' then return end
if GetResourceState('t-notify') ~= 'started' then return end

local mod = {
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    Send = function(message, notifType, duration)
        duration = duration or 3000
        exports['t-notify']:Alert({ style = notifType or 'info', message = message, duration = duration })
    end,
}

RegisterNetEvent('o-link:client:notify', function(message, notifType, duration)
    mod.Send(message, notifType, duration)
end)

olink._register('notify', mod)
