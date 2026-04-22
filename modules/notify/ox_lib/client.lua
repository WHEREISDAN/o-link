if not olink._guardImpl('Notify', 'ox_lib', 'ox_lib') then return end
if not olink._hasOverride('Notify') and GetResourceState('oxide-notify') == 'started' then return end

local mod = {
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    ---@param title string|nil
    ---@param props table|nil extra ox_lib notify props (icon, position, etc.)
    Send = function(message, notifType, duration, title, props)
        local payload = {
            title = title,
            description = message,
            type = notifType or 'inform',
            duration = duration,
        }
        if props then
            for k, v in pairs(props) do payload[k] = v end
        end
        lib.notify(payload)
    end,
}

RegisterNetEvent('o-link:client:notify', function(message, notifType, duration, title, props)
    mod.Send(message, notifType, duration, title, props)
end)

olink._register('notify', mod)
