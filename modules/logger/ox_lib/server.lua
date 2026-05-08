-- Default logger adapter: routes through ox_lib's `lib.logger` when configured
-- (Datadog / Fivemanage / Loki via the `ox:logger` convar) and prints to console
-- otherwise. oxide-logger overrides this when installed (alphabetical load order).

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

local function flattenData(data)
    if type(data) ~= 'table' then return nil end
    local parts = {}
    for k, v in pairs(data) do
        local sv
        if type(v) == 'table' then
            local ok, encoded = pcall(json.encode, v)
            sv = ok and encoded or '<unencodable>'
        else
            sv = tostring(v)
        end
        parts[#parts + 1] = ('%s=%s'):format(tostring(k), sv)
    end
    return parts
end

local function consolePrint(level, resource, category, message, data)
    local tag = LevelTag[level] or 'INFO'
    local color = level >= Levels.error and '^1' or level == Levels.warn and '^3' or '^7'
    local line = ('%s[%s][%s][%s] %s^7'):format(color, tag, resource or '-', category or '-', message or '')
    print(line)
    if data ~= nil then
        local ok, encoded = pcall(json.encode, data)
        if ok and encoded then print('  ' .. encoded) end
    end
end

local function emit(level, resource, category, message, data)
    if level < thresholdFor(resource) then return false end

    consolePrint(level, resource, category, message, data)

    if lib and lib.logger then
        local tags = { 'resource:' .. tostring(resource or '-'), 'level:' .. (LevelTag[level] or 'INFO') }
        local flat = flattenData(data)
        if flat then for _, t in ipairs(flat) do tags[#tags + 1] = t end end
        pcall(lib.logger, 0, category or '-', message or '', table.unpack(tags))
    end

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

    CaptureError = function(resource, errorMessage, traceback, source)
        return emit(Levels.error, resource or 'unknown', 'error', tostring(errorMessage),
            { traceback = traceback, source = source })
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

    SetLevel = function(resource, level)
        local n
        if type(level) == 'string' then n = Levels[level:lower()]
        elseif type(level) == 'number' and level >= 1 and level <= 6 then n = level end
        if not n then return false end
        resourceLevels[resource] = n
        return true
    end,

    GetLevel = function(resource)
        local n = thresholdFor(resource)
        return (LevelTag[n] or 'INFO'):lower()
    end,
}, RESOURCE)
