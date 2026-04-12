if GetResourceState('oxide-notify') == 'started' then return end
if GetResourceState('lation_ui') ~= 'started' then return end

local mod = {
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    Send = function(message, notifType, duration)
        duration = duration or 3000
        exports.lation_ui:notify({ message = message, type = notifType or 'success', duration = duration, position = 'top-right' })
    end,
}

RegisterNetEvent('o-link:client:notify', function(message, notifType, duration)
    mod.Send(message, notifType, duration)
end)

olink._register('notify', mod)
