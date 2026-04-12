-- Server-side notify relay: fires a client event that the client notify module listens to.
olink._register('notify', {
    ---@param src number
    ---@param message string
    ---@param notifType string|nil
    ---@param duration number|nil
    Send = function(src, message, notifType, duration)
        TriggerClientEvent('o-link:client:notify', src, message, notifType, duration)
    end,
})
