olink = {}

local capabilities = {}
local warnedCalls = {}

local side = IsDuplicityVersion() and 'server' or 'client'

---Print a one-time warning when a stub function is called because no real implementation is loaded.
---@param namespace string
---@param fn string
function olink._warnMissing(namespace, fn)
    local key = namespace .. '.' .. fn
    if warnedCalls[key] then return end
    warnedCalls[key] = true
    print(('^3[o-link] %s: olink.%s() was called but no "%s" module is loaded. Returning defaults. Use olink.supports(%q) to guard optional features.^0')
        :format(side, key, namespace, key))
end

local overrideKeyMap = {
    framework = 'Framework',
    character = 'Character',
    job = 'Job',
    money = 'Money',
    inventory = 'Inventory',
    vehicles = 'Vehicles',
    vehicleproperties = 'VehicleProperties',
    vehicleownership = 'VehicleOwnership',
    notify = 'Notify',
    banking = 'Banking',
    helptext = 'HelpText',
    target = 'Target',
    progressbar = 'ProgressBar',
    vehiclekey = 'VehicleKey',
    fuel = 'Fuel',
    weather = 'Weather',
    input = 'Input',
    menu = 'Menu',
    zones = 'Zones',
    phone = 'Phone',
    clothing = 'Clothing',
    dispatch = 'Dispatch',
    doorlock = 'Doorlock',
    housing = 'Housing',
    bossmenu = 'BossMenu',
    skills = 'Skills',
    death = 'Death',
    needs = 'Needs',
    gang = 'Gang',
}

local function normalizeName(value)
    return type(value) == 'string' and value:lower() or nil
end

---Merge functions from `impl` into the namespace table. Existing entries are overwritten.
---@param namespace string
---@param impl table
local function mergeImpl(namespace, impl)
    local existing = rawget(olink, namespace)
    if type(existing) ~= 'table' then
        existing = {}
        olink[namespace] = existing
    end
    for k, v in pairs(impl) do
        existing[k] = v
    end
end

---Register a real implementation for a namespace. Flips the capability flag so
---`olink.supports()` returns true for loaded functions.
---@param namespace string Module namespace (e.g. 'framework', 'character', 'job')
---@param impl table Table of functions returned by the module implementation
function olink._register(namespace, impl)
    mergeImpl(namespace, impl)
    capabilities[namespace] = true
end

---Register a default/stub implementation for a namespace. Does NOT flip the
---capability flag — `olink.supports()` still returns false. Real implementations
---loaded later will overwrite these stubs.
---@param namespace string
---@param impl table
function olink._registerDefault(namespace, impl)
    mergeImpl(namespace, impl)
end

---Build a stub table of warning-return functions for the given namespace.
---@param namespace string
---@param methods string[] List of method names to stub.
---@param defaults? table<string, any> Optional map of name -> default return value (or function returning defaults).
---@return table
function olink._buildStub(namespace, methods, defaults)
    defaults = defaults or {}
    local stub = {}
    for _, name in ipairs(methods) do
        local default = defaults[name]
        if type(default) == 'function' then
            stub[name] = function(...)
                olink._warnMissing(namespace, name)
                return default(...)
            end
        else
            local captured = default
            stub[name] = function()
                olink._warnMissing(namespace, name)
                return captured
            end
        end
    end
    return stub
end

---@param namespace string
---@return string
function olink._getOverrideKey(namespace)
    return overrideKeyMap[normalizeName(namespace)] or namespace
end

---@param namespace string
---@return string|nil
function olink._getOverride(namespace)
    local overrides = Config and Config.Overrides
    if type(overrides) ~= 'table' then return nil end

    local key = olink._getOverrideKey(namespace)
    local value = overrides[key]
    if type(value) ~= 'string' or value == '' then return nil end

    return value
end

---@param namespace string
---@param implName string
---@return boolean|nil
function olink._overrideMatches(namespace, implName)
    local override = olink._getOverride(namespace)
    if not override then return nil end

    return normalizeName(override) == normalizeName(implName)
end

---@param namespace string
---@return boolean
function olink._hasOverride(namespace)
    return olink._getOverride(namespace) ~= nil
end

---@param namespace string
---@param implName string
---@param resourceName string|false|nil
---@return boolean
function olink._guardImpl(namespace, implName, resourceName)
    local matches = olink._overrideMatches(namespace, implName)
    if matches == false then return false end

    if resourceName == false then return true end

    local state = GetResourceState(resourceName or implName)
    if state ~= 'started' and state ~= 'missing' and Config and Config.Debug then
        print(('[o-link] %s adapter "%s" skipped: resource "%s" is %s (not started)')
            :format(namespace, implName, resourceName or implName, state))
    end
    return state == 'started'
end

---Check whether a module or specific function is available.
---@param path string Dot-separated path (e.g. 'character', 'character.SetBoss')
---@return boolean
function olink.supports(path)
    local first = true
    local node = olink
    for part in path:gmatch('[^.]+') do
        if type(node) ~= 'table' then return false end
        if first then
            if not capabilities[part] then return false end
            node = rawget(olink, part)
            first = false
        else
            node = rawget(node, part)
        end
        if node == nil then return false end
    end
    return not first
end

---@return table<string, boolean> Map of loaded module namespaces
function olink._getCapabilities()
    return capabilities
end

---Strip .png / .webp extension from an item name for image path resolution.
---@param item string
---@return string
function olink._stripExt(item)
    return item:gsub('%.png$', ''):gsub('%.webp$', '')
end

exports('olink', function()
    return olink
end)
