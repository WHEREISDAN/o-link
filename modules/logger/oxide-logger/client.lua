local RESOURCE = 'oxide-logger'

if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Logger', RESOURCE, false) then return end

local res = exports[RESOURCE]

local function isStarted()
    return GetResourceState(RESOURCE) == 'started'
end

olink._register('logger', {
    ---@return string
    GetResourceName = function() return RESOURCE end,

    Trace = function(resource, category, message, data)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:Trace(resource, category, message, data) end)
        return ok and result == true
    end,

    Debug = function(resource, category, message, data)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:Debug(resource, category, message, data) end)
        return ok and result == true
    end,

    Info = function(resource, category, message, data)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:Info(resource, category, message, data) end)
        return ok and result == true
    end,

    Warn = function(resource, category, message, data)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:Warn(resource, category, message, data) end)
        return ok and result == true
    end,

    Error = function(resource, category, message, data)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:Error(resource, category, message, data) end)
        return ok and result == true
    end,

    Fatal = function(resource, category, message, data)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:Fatal(resource, category, message, data) end)
        return ok and result == true
    end,

    Event = function(resource, category, eventName, data)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:Event(resource, category, eventName, data) end)
        return ok and result == true
    end,

    CaptureError = function(resource, errorMessage, traceback)
        if not isStarted() then return false end
        local ok = pcall(function() res:CaptureError(resource, errorMessage, traceback) end)
        return ok
    end,

    SafeCall = function(fn, resource, category)
        if type(fn) ~= 'function' then return nil end
        if not isStarted() then
            local ok, result = pcall(fn)
            if ok then return result end
            return nil
        end
        local function handler(err)
            local tb = debug.traceback(tostring(err), 2)
            pcall(function() res:CaptureError(resource or 'unknown', tostring(err), tb) end)
            return tb
        end
        local ok, result = xpcall(fn, handler)
        if ok then return result end
        return nil
    end,
}, RESOURCE)
