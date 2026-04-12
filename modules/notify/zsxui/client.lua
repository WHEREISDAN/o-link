if GetResourceState('oxide-notify') == 'started' then return end
if GetResourceState('ZSX_UIV2') ~= 'started' then return end

local function iconForType(notifType)
    if notifType == 'success' then return 'check-circle'
    elseif notifType == 'error' then return 'times-circle'
    elseif notifType == 'warning' then return 'exclamation-triangle'
    end
    return 'info'
end

local mod = {
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    Send = function(message, notifType, duration)
        duration = duration or 3000
        exports['ZSX_UIV2']:Notification('Notification', message, iconForType(notifType), duration)
    end,
}

RegisterNetEvent('o-link:client:notify', function(message, notifType, duration)
    mod.Send(message, notifType, duration)
end)

olink._register('notify', mod)
