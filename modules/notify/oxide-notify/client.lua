if GetResourceState('oxide-notify') == 'missing' then return end

local mod = {
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    Send = function(message, notifType, duration)
        exports['oxide-notify']:Notify({
            message = message,
            type = notifType,
            duration = duration,
        })
    end,
}

-- Listen for server-side Send() relay
RegisterNetEvent('o-link:client:notify', function(message, notifType, duration)
    mod.Send(message, notifType, duration)
end)

olink._register('notify', mod)
