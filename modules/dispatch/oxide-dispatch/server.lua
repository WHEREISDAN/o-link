if not olink._guardImpl('Dispatch', 'oxide-dispatch', 'oxide-dispatch') then return end

local dispatch = exports['oxide-dispatch']

olink._register('dispatch', {
    ---@return string
    GetResourceName = function() return 'oxide-dispatch' end,

    ---Server-authored alert (911, panic, manual, system).
    ---@param data table
    ---@return table|nil
    CreateAlert = function(data)
        return dispatch:CreateAlert(data)
    end,

    ---@param jobFilter? string|string[]
    ---@return table[]
    GetActiveAlerts = function(jobFilter)
        if GetResourceState('oxide-dispatch') ~= 'started' then return {} end
        return dispatch:GetActiveAlerts(jobFilter) or {}
    end,

    ---@param alertId integer
    ---@return table|nil
    GetAlert = function(alertId)
        return dispatch:GetAlert(alertId)
    end,

    ---@param alertId integer
    ---@param src integer
    ---@return boolean, string|nil
    RespondToAlert = function(alertId, src)
        return dispatch:RespondToAlert(alertId, src)
    end,

    ---@param alertId integer
    ---@param src integer
    ---@return boolean
    StopResponding = function(alertId, src)
        return dispatch:StopResponding(alertId, src)
    end,

    ---@param alertId integer
    ---@param src integer
    ---@param status 'responding'|'on_scene'|'cleared'
    ---@return boolean
    UpdateResponderStatus = function(alertId, src, status)
        return dispatch:UpdateResponderStatus(alertId, src, status)
    end,

    ---@param alertId integer
    ---@param src? integer
    ---@param reason? string
    ---@return boolean, string|nil
    CloseAlert = function(alertId, src, reason)
        return dispatch:CloseAlert(alertId, src, reason)
    end,
})
