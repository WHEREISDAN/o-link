-- Server-side notify relay: fires a client event that the client notify module listens to.
local pendingConfirms = {}

local function getNotifyResourceName()
    local override = olink._getOverride('Notify')
    if override then
        return override
    end

    local resourceNames = {
        'brutal_notify',
        'fl-notify',
        'lation_ui',
        'mythic_notify',
        'okokNotify',
        'ox_lib',
        'oxide-notify',
        'pNotify',
        'r_notify',
        't-notify',
        'wasabi_notify',
        'ZSX_UIV2',
        'zsxui',
    }

    for _, resourceName in ipairs(resourceNames) do
        if GetResourceState(resourceName) == 'started' then
            return resourceName
        end
    end

    return '_default'
end

olink._register('notify', {
    GetResourceName = function()
        return getNotifyResourceName()
    end,

    ---@param src number
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    ---@param title string|nil optional title shown above the message when the adapter supports it
    ---@param props table|nil optional extra props (icon, position, etc.)
    Send = function(src, message, notifType, duration, title, props)
        TriggerClientEvent('o-link:client:notify', src, message, notifType, duration, title, props)
    end,

    ---Community_bridge-style alias accepting title as the first data argument.
    ---@param src number
    ---@param title string|nil
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    ---@param props table|nil
    SendNotification = function(src, title, message, notifType, duration, props)
        TriggerClientEvent('o-link:client:notify', src, message, notifType, duration, title, props)
    end,

    ---@param src number
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    SendNotify = function(src, message, notifType, duration)
        TriggerClientEvent('o-link:client:notify', src, message, notifType, duration, nil, nil)
    end,

    ---@param src number
    ---@param options table { title?, message?, timeout?, acceptLabel?, declineLabel? }
    ---@param callback function(accepted: boolean)
    Confirm = function(src, options, callback)
        local confirmId = ('%x%x'):format(math.random(0, 0x7FFFFFFF), math.random(0, 0x7FFFFFFF))
        pendingConfirms[src] = { id = confirmId, callback = callback }
        TriggerClientEvent('o-link:client:confirm', src, confirmId, options)
    end,
})

RegisterNetEvent('o-link:server:confirmResponse', function(confirmId, accepted)
    local src = source
    local pending = pendingConfirms[src]
    if pending and pending.id == confirmId then
        if pending.callback then pending.callback(accepted) end
        pendingConfirms[src] = nil
    end
end)
