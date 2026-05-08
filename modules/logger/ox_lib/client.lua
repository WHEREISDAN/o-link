-- Default client logger adapter. ox_lib does not ship a client logger, so this
-- forwards to the server adapter. oxide-logger overrides this when installed.

local RESOURCE = 'ox_lib'

if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Logger', RESOURCE, false) then return end

local Levels   = { trace = 1, debug = 2, info = 3, warn = 4, error = 5, fatal = 6 }
local LevelTag = { 'TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL' }
local resourceLevels = {}
local defaultLevel = Levels.info

local function thresholdFor(resource)
    return resourceLevels[resource] or defaultLevel
end

local function consolePrint(level, resource, category, message, data)
    local tag = LevelTag[level] or 'INFO'
    local color = level >= Levels.error and '^1' or level == Levels.warn and '^3' or '^7'
    print(('%s[%s][%s][%s] %s^7'):format(color, tag, resource or '-', category or '-', message or ''))
    if data ~= nil then
        local ok, encoded = pcall(json.encode, data)
        if ok and encoded then print('  ' .. encoded) end
    end
end

local function emit(level, resource, category, message, data)
    if level < thresholdFor(resource) then return false end
    consolePrint(level, resource, category, message, data)
    return true
end

olink._register('logger', {
    GetResourceName = function() return RESOURCE end,
    Trace = function(r, c, m, d) return emit(Levels.trace, r, c, m, d) end,
    Debug = function(r, c, m, d) return emit(Levels.debug, r, c, m, d) end,
    Info  = function(r, c, m, d) return emit(Levels.info,  r, c, m, d) end,
    Warn  = function(r, c, m, d) return emit(Levels.warn,  r, c, m, d) end,
    Error = function(r, c, m, d) return emit(Levels.error, r, c, m, d) end,
    Fatal = function(r, c, m, d) return emit(Levels.fatal, r, c, m, d) end,
    Event = function(r, c, m, d) return emit(Levels.info,  r, c, m, d) end,

    CaptureError = function(resource, errorMessage, traceback)
        return emit(Levels.error, resource or 'unknown', 'error', tostring(errorMessage),
            { traceback = traceback })
    end,

    SafeCall = function(fn, resource, category)
        if type(fn) ~= 'function' then return nil end
        local ok, result = xpcall(fn, function(err)
            local tb = debug.traceback(tostring(err), 2)
            emit(Levels.error, resource or 'unknown', category or 'error', tostring(err),
                { traceback = tb })
            return tb
        end)
        if ok then return result end
        return nil
    end,
}, RESOURCE)
