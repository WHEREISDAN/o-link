if not olink._guardImpl('Dispatch', 'oxide-dispatch', 'oxide-dispatch') then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function() return 'oxide-dispatch' end,

    ---Submit a new alert.
    ---@param data table
    SendAlert = function(data)
        if type(data) ~= 'table' then return end
        local ped = PlayerPedId()
        TriggerServerEvent('oxide:dispatch:sendAlert', {
            code          = data.code,
            title         = data.title,
            message       = data.message,
            priority      = data.priority,
            icon          = data.icon,
            jobs          = data.jobs or data.job,
            coords        = data.coords or GetEntityCoords(ped),
            vehicle_model = data.vehicle_model or data.vehicle,
            vehicle_plate = data.vehicle_plate or data.plate,
            blipData      = data.blipData,
            expireMinutes = data.expireMinutes,
            source_type   = data.source_type,
        })
    end,

    ---@param jobFilter? string|string[]
    ---@return table[]
    GetActiveAlerts = function(jobFilter)
        return olink.callback.Trigger('oxide-dispatch:server:getActiveAlerts', jobFilter) or {}
    end,

    ---@param alertId integer
    GetAlert = function(alertId)
        return olink.callback.Trigger('oxide-dispatch:server:getAlert', alertId)
    end,

    ---@param alertId integer
    RespondToAlert = function(alertId)
        return olink.callback.Trigger('oxide-dispatch:server:respond', alertId)
    end,

    ---@param alertId integer
    StopResponding = function(alertId)
        return olink.callback.Trigger('oxide-dispatch:server:stopResponding', alertId)
    end,

    ---@param alertId integer
    ---@param status 'responding'|'on_scene'|'cleared'
    UpdateResponderStatus = function(alertId, status)
        return olink.callback.Trigger('oxide-dispatch:server:setResponderStatus', alertId, status)
    end,

    ---@param alertId integer
    ---@param reason? string
    CloseAlert = function(alertId, reason)
        return olink.callback.Trigger('oxide-dispatch:server:closeAlert', alertId, reason)
    end,
})
