local RESOURCE = 'oxide-tablet'

-- Pure adapter: bail if the tablet isn't installed so the defaults stub owns
-- the namespace and consumers fall back to their own UI.
if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Tablet', RESOURCE, false) then return end

local res = exports[RESOURCE]

local function isStarted()
    return GetResourceState(RESOURCE) == 'started'
end

olink._register('tablet', {
    ---@return string
    GetResourceName = function() return RESOURCE end,

    ---Register an app the tablet can host. `def.resource` is required: by the
    ---time the call reaches the tablet the invoking resource is o-link itself.
    ---@param def table { id, label, icon, resource, url?, query?, requires?, order?, color?, readyTimeoutMs? }
    ---@return boolean
    RegisterApp = function(def)
        if type(def) ~= 'table' then return false end
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:RegisterApp(def) end)
        return ok and result == true
    end,

    ---@param id string
    ---@return boolean
    UnregisterApp = function(id)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:UnregisterApp(id) end)
        return ok and result == true
    end,

    ---Open the tablet, optionally straight into an app. Idempotent for the current app.
    ---@param appId? string
    ---@return boolean
    Open = function(appId)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:Open(appId) end)
        return ok and result == true
    end,

    ---@return boolean
    Close = function()
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:Close() end)
        return ok and result == true
    end,

    ---Return to the launcher if `appId` is the current app.
    ---@param appId string
    ---@return boolean
    CloseApp = function(appId)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:CloseApp(appId) end)
        return ok and result == true
    end,

    ---@return boolean
    IsOpen = function()
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:IsOpen() end)
        return ok and result == true
    end,

    ---@return string|nil
    GetCurrentApp = function()
        if not isStarted() then return nil end
        local ok, result = pcall(function() return res:GetCurrentApp() end)
        return ok and result or nil
    end,

    ---Relay a `{ action, data }` message into the current app's iframe.
    ---Queued by the tablet until the app reports ready.
    ---@param appId string
    ---@param message table
    ---@return boolean
    Send = function(appId, message)
        if type(message) ~= 'table' then return false end
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:Send(appId, message) end)
        return ok and result == true
    end,

    ---@param appId string
    ---@param count number
    ---@return boolean
    SetBadge = function(appId, count)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:SetBadge(appId, count) end)
        return ok and result == true
    end,
}, RESOURCE)
