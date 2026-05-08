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

    ---@param resource string
    ---@param category string
    ---@param message string
    ---@param data? table
    ---@return boolean
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

    ---@param resource string
    ---@param category string
    ---@param eventName string
    ---@param data? table
    Event = function(resource, category, eventName, data)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:Event(resource, category, eventName, data) end)
        return ok and result == true
    end,

    ---@param resource string
    ---@param errorMessage string
    ---@param traceback? string
    ---@param source? integer
    CaptureError = function(resource, errorMessage, traceback, source)
        if not isStarted() then return false end
        local ok = pcall(function() res:CaptureError(resource, errorMessage, traceback, source) end)
        return ok
    end,

    ---@param fn function
    ---@param resource string
    ---@param category? string
    SafeCall = function(fn, resource, category)
        if not isStarted() then
            -- Adapter-side fallback so consumers calling SafeCall during
            -- the boot window still get xpcall semantics.
            if type(fn) ~= 'function' then return nil end
            local ok, result = pcall(fn)
            if ok then return result end
            return nil
        end
        -- Function values can't be marshalled across resource boundaries via
        -- exports, so we run xpcall locally and hand any error back to the
        -- logger via CaptureError.
        if type(fn) ~= 'function' then return nil end
        local function handler(err)
            local tb = debug.traceback(tostring(err), 2)
            pcall(function() res:CaptureError(resource or 'unknown', tostring(err), tb, nil) end)
            return tb
        end
        local ok, result = xpcall(fn, handler)
        if ok then return result end
        return nil
    end,

    ---@param resource string
    ---@param level string
    ---@return boolean
    SetLevel = function(resource, level)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:SetLevel(resource, level) end)
        return ok and result == true
    end,

    ---@param resource string
    ---@return string
    GetLevel = function(resource)
        if not isStarted() then return 'info' end
        local ok, result = pcall(function() return res:GetLevel(resource) end)
        return ok and result or 'info'
    end,
}, RESOURCE)
