-- Adapter for oxide-dispatch. Registers IMMEDIATELY so consumers that snapshot
-- olink across the resource boundary capture real wrapper refs, not stubs.
-- See .claude/rules/community-bridge-usage.md.

local RESOURCE = 'oxide-dispatch'

-- Pure adapter: bail if the resource isn't installed so other dispatch impls
-- (ps-dispatch, cd_dispatch, _default event-relay, etc.) own the namespace.
if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Dispatch', RESOURCE, false) then return end

local res = exports[RESOURCE]

local function isStarted()
    return GetResourceState(RESOURCE) == 'started'
end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function() return RESOURCE end,

    ---Server-authored alert (911, panic, manual, system).
    ---@param data table
    ---@return table|nil
    CreateAlert = function(data)
        if not isStarted() then return nil end
        local ok, result = pcall(function() return res:CreateAlert(data) end)
        return ok and result or nil
    end,

    ---@param jobFilter? string|string[]
    ---@return table[]
    GetActiveAlerts = function(jobFilter)
        if not isStarted() then return {} end
        local ok, result = pcall(function() return res:GetActiveAlerts(jobFilter) end)
        return ok and result or {}
    end,

    ---@param alertId integer
    ---@return table|nil
    GetAlert = function(alertId)
        if not isStarted() then return nil end
        local ok, result = pcall(function() return res:GetAlert(alertId) end)
        return ok and result or nil
    end,

    ---@param alertId integer
    ---@param src integer
    ---@return boolean, string|nil
    RespondToAlert = function(alertId, src)
        if not isStarted() then return false, 'unavailable' end
        local ok, success, err = pcall(function() return res:RespondToAlert(alertId, src) end)
        if not ok then return false, 'unavailable' end
        return success, err
    end,

    ---@param alertId integer
    ---@param src integer
    ---@return boolean
    StopResponding = function(alertId, src)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:StopResponding(alertId, src) end)
        return ok and result == true
    end,

    ---@param alertId integer
    ---@param src integer
    ---@param status 'responding'|'on_scene'|'cleared'
    ---@return boolean
    UpdateResponderStatus = function(alertId, src, status)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:UpdateResponderStatus(alertId, src, status) end)
        return ok and result == true
    end,

    ---@param alertId integer
    ---@param src? integer
    ---@param reason? string
    ---@return boolean, string|nil
    CloseAlert = function(alertId, src, reason)
        if not isStarted() then return false, 'unavailable' end
        local ok, success, err = pcall(function() return res:CloseAlert(alertId, src, reason) end)
        if not ok then return false, 'unavailable' end
        return success, err
    end,
}, RESOURCE)
