-- Adapter for oxide-dispatch (client). Registers IMMEDIATELY so consumers that
-- snapshot olink across the resource boundary capture real wrapper refs, not stubs.

local RESOURCE = 'oxide-dispatch'

-- Pure adapter: bail if the resource isn't installed so other dispatch impls
-- own the namespace.
if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Dispatch', RESOURCE, false) then return end

local function isStarted()
    return GetResourceState(RESOURCE) == 'started'
end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function() return RESOURCE end,

    ---Submit a new alert.
    ---@param data table
    SendAlert = function(data)
        if type(data) ~= 'table' then return end
        if not isStarted() then return end
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
        if not isStarted() then return {} end
        return olink.callback.Trigger('oxide-dispatch:server:getActiveAlerts', jobFilter) or {}
    end,

    ---@param alertId integer
    GetAlert = function(alertId)
        if not isStarted() then return nil end
        return olink.callback.Trigger('oxide-dispatch:server:getAlert', alertId)
    end,

    ---@param alertId integer
    RespondToAlert = function(alertId)
        if not isStarted() then return false end
        return olink.callback.Trigger('oxide-dispatch:server:respond', alertId)
    end,

    ---@param alertId integer
    StopResponding = function(alertId)
        if not isStarted() then return false end
        return olink.callback.Trigger('oxide-dispatch:server:stopResponding', alertId)
    end,

    ---@param alertId integer
    ---@param status 'responding'|'on_scene'|'cleared'
    UpdateResponderStatus = function(alertId, status)
        if not isStarted() then return false end
        return olink.callback.Trigger('oxide-dispatch:server:setResponderStatus', alertId, status)
    end,

    ---@param alertId integer
    ---@param reason? string
    CloseAlert = function(alertId, reason)
        if not isStarted() then return false end
        return olink.callback.Trigger('oxide-dispatch:server:closeAlert', alertId, reason)
    end,
}, RESOURCE)
