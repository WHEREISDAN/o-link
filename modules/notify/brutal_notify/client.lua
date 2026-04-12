if GetResourceState('oxide-notify') == 'started' then return end
if GetResourceState('brutal_notify') ~= 'started' then return end

local mod = {
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    Send = function(message, notifType, duration)
        duration = duration or 3000
        exports['brutal_notify']:SendAlert('Notification', message, duration, notifType or 'success', false)
    end,
}

RegisterNetEvent('o-link:client:notify', function(message, notifType, duration)
    mod.Send(message, notifType, duration)
end)

olink._register('notify', mod)
