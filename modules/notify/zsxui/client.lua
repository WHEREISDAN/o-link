if not olink._guardImpl('Notify', 'zsxui', 'ZSX_UIV2') then return end

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
    ---@param title string|nil
    Send = function(message, notifType, duration, title)
        duration = duration or 3000
        exports['ZSX_UIV2']:Notification(title or 'Notification', message, iconForType(notifType), duration)
    end,
}

RegisterNetEvent('o-link:client:notify', function(message, notifType, duration, title)
    mod.Send(message, notifType, duration, title)
end)

olink._register('notify', mod, 'ZSX_UIV2')
