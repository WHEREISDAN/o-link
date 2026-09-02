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
}, RESOURCE)
