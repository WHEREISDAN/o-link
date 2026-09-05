local RESOURCE = 'oxide-tablet'

if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Tablet', RESOURCE, false) then return end

local res = exports[RESOURCE]

local function isStarted()
    return GetResourceState(RESOURCE) == 'started'
end

olink._register('tablet', {
    ---@return string
    GetResourceName = function() return RESOURCE end,

    ---Open a player's tablet, optionally straight into an app.
    ---@param src number
    ---@param appId? string
    ---@return boolean
    Open = function(src, appId)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:Open(src, appId) end)
        return ok and result == true
    end,

    ---@param src number
    ---@return boolean
    Close = function(src)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:Close(src) end)
        return ok and result == true
    end,

    ---Relay a `{ action, data }` message into a player's current app.
    ---@param src number
    ---@param appId string
    ---@param message table
    ---@return boolean
    Send = function(src, appId, message)
        if type(message) ~= 'table' then return false end
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:Send(src, appId, message) end)
        return ok and result == true
    end,

    ---The device (IMEI) the player's open tablet was started on. nil when the tablet is
    ---not open, was opened by a resource rather than an item, or the inventory cannot
    ---keep item metadata.
    ---@param src number
    ---@return table|nil { imei, name, item, slot }
    GetDevice = function(src)
        if not isStarted() then return nil end
        local ok, result = pcall(function() return res:GetDevice(src) end)
        return ok and type(result) == 'table' and result or nil
    end,

    ---Relay widget data to a player's tablet (client SetWidgetData).
    ---@param src number
    ---@param id string
    ---@param data table|nil
    ---@return boolean
    SetWidgetData = function(src, id, data)
        if data ~= nil and type(data) ~= 'table' then return false end
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:SetWidgetData(src, id, data) end)
        return ok and result == true
    end,
}, RESOURCE)
