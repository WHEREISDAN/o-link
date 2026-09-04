-- `/oxide:diag` writes a support snapshot of this server to `diag/diag-<epoch>.json`.
-- It lives in o-link rather than oxide-logger because o-link is a hard dependency
-- of every product, so every customer can produce one with no extra install.
--
-- This is support tooling, so it is built for the broken case: the snapshot must
-- still be written when providers are all fallback stubs, when oxide-logger is
-- absent, and when consumer resources failed to start. Every read that leaves
-- o-link goes through `safe()`, which records the failure in the snapshot instead
-- of aborting the write -- "this was unreachable" is often the actual diagnosis.

local RESOURCE = GetCurrentResourceName()

-- The auto-updater never overwrites config.lua, so customers who update o-link
-- keep a config with no Config.Diag block. Every key has to default.
local function cfg(key, default)
    local diag = rawget(_G, 'Config') and Config.Diag
    local value = diag and diag[key]
    if value == nil then return default end
    return value
end

-- FiveM's json.encode cannot store a nil value in a table, and Lua has no null.
-- Emitting the key with this sentinel and swapping it after encoding is the only
-- way to produce a literal `null` rather than dropping the field. Contains no Lua
-- pattern magic characters, so the gsub below is a plain match.
local NULL = '@@OXIDE_DIAG_NULL@@'

local function collector()
    local failures = {}
    local function safe(field, fn, default)
        local ok, result = pcall(fn)
        if ok then return result end
        failures[#failures + 1] = { field = field, error = tostring(result) }
        return default
    end
    return safe, failures
end

local function readVersion(safe, resource)
    return safe('version.' .. resource, function()
        if GetResourceState(resource) == 'missing' then return nil end
        local v = GetResourceMetadata(resource, 'version', 0)
        return v ~= '' and v or nil
    end)
end

-- Case-insensitive index of the generated provider catalog, so casing drift in a
-- resource folder name (bigDaddy-Fuel, PolyZone) still resolves to a role tag.
local knownRoles = {}
for name, role in pairs(rawget(_G, 'OxideKnownProviders') or {}) do
    knownRoles[name:lower()] = role
end

-- Every resource on the server, not just oxide-*. The old oxide-* + 4-name filter
-- hid third-party providers, which is exactly what ticket 0340 (hex_4_inventory)
-- turned out to be.
local function listResources(safe)
    local counts = { total = 0, started = 0, stopped = 0 }
    local list = {}
    local total = safe('resources.count', GetNumResources, 0) or 0

    for i = 0, total - 1 do
        local name = safe('resources.index.' .. i, function() return GetResourceByFindIndex(i) end)
        if name then
            local state = safe('resources.state.' .. name, function() return GetResourceState(name) end, 'unknown') or 'unknown'
            list[#list + 1] = {
                name    = name,
                state   = state,
                version = readVersion(safe, name),
                role    = knownRoles[name:lower()],
            }
            counts.total = counts.total + 1
            if state == 'started' then
                counts.started = counts.started + 1
            elseif state == 'stopped' then
                counts.stopped = counts.stopped + 1
            end
        end
    end

    table.sort(list, function(a, b) return a.name < b.name end)
    return list, counts
end

local function listNamespaces(safe)
    local caps = safe('olink.capabilities', function()
        return olink._getCapabilities and olink._getCapabilities() or {}
    end, {}) or {}

    local providers = {}
    for namespace, info in pairs(caps) do
        -- `provider` is recorded by _register for every adapter; the GetResourceName
        -- call is the fallback for adapters registered without an implName.
        local providerName = info.provider
        if not providerName then
            providerName = safe('namespace.' .. namespace, function()
                local ns = rawget(olink, namespace)
                if type(ns) == 'table' and ns.GetResourceName then return ns.GetResourceName() end
                return nil
            end)
        end
        providers[namespace] = {
            kind     = info.kind,
            loaded   = info.loaded,
            provider = providerName,
        }
    end
    return providers
end

-- oxide-logger is optional enrichment. Gate on the resource state rather than
-- olink.supports('logger.*'), which is always true because defaults_server.lua
-- stubs the namespace whether or not a real provider exists.
local function recentErrors(safe)
    if GetResourceState('oxide-logger') ~= 'started' then return nil end
    return safe('recent_errors', function()
        if not (olink.logger and olink.logger.GetRecentErrors) then return nil end
        return olink.logger.GetRecentErrors(cfg('RecentErrors', 50))
    end)
end

local function buildSnapshot()
    local safe, failures = collector()

    local errors = recentErrors(safe)
    local resources, counts = listResources(safe)

    local snapshot = {
        generated_at = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        host = {
            artifact_version = safe('host.artifact_version', function() return GetConvar('version', 'unknown') end, 'unknown'),
            server_name      = safe('host.server_name', function() return GetConvar('sv_projectName', 'unknown') end, 'unknown'),
            description      = safe('host.description', function() return GetConvar('sv_projectDesc', '') end, ''),
            game_build       = safe('host.game_build', function() return GetConvar('sv_enforceGameBuild', 'unknown') end, 'unknown'),
            onesync          = safe('host.onesync', function() return GetConvar('onesync', 'unknown') end, 'unknown'),
        },
        framework = safe('framework', function()
            return olink.framework and olink.framework.GetName and olink.framework.GetName() or 'unknown'
        end, 'unknown') or 'unknown',
        olink = {
            version    = readVersion(safe, RESOURCE),
            namespaces = listNamespaces(safe),
        },
        versions = {
            ox_lib           = readVersion(safe, 'ox_lib'),
            oxmysql          = readVersion(safe, 'oxmysql'),
            ['o-link']       = readVersion(safe, 'o-link'),
            ['oxide-logger'] = readVersion(safe, 'oxide-logger'),
        },
        resources       = resources,
        resource_counts = counts,
        recent_errors   = errors or NULL,
    }

    if not errors then
        snapshot.note = 'install oxide-logger for captured error history'
    end
    if #failures > 0 then
        snapshot.collection_errors = failures
    end

    return snapshot
end

local function writeSnapshot(snapshot)
    local relPath = ('%s/diag-%d.json'):format(cfg('SnapshotDir', 'diag'), os.time())
    local ok, encoded = pcall(json.encode, snapshot)
    if not ok or type(encoded) ~= 'string' then
        print(('^1[oxide:diag]^7 could not encode snapshot: %s^0'):format(tostring(encoded)))
        return nil
    end

    encoded = encoded:gsub('"' .. NULL .. '"', 'null')

    -- SaveResourceFile does not create parent dirs; the snapshot dir ships in the
    -- repo as `diag/.gitignore`, which also keeps snapshots out of git.
    if not SaveResourceFile(RESOURCE, relPath, encoded, -1) then
        print(('^1[oxide:diag]^7 SaveResourceFile failed for %q^0'):format(relPath))
        return nil
    end
    return relPath
end

local function isAuthorized(src)
    if src == 0 then return true end

    local ace = cfg('RequireAce', 'command.oxide:diag')
    if ace and ace ~= '' and IsPlayerAceAllowed(tostring(src), ace) then return true end

    local ok, isAdmin = pcall(function()
        return olink.framework and olink.framework.IsAdmin and olink.framework.IsAdmin(src)
    end)
    return (ok and isAdmin) and true or false
end

local function reply(src, message, notifyType)
    if src == 0 then
        print(message)
        return
    end
    pcall(function() olink.notify.Send(src, (message:gsub('%^%d', '')), notifyType) end)
    pcall(function() TriggerClientEvent('chat:addMessage', src, { args = { '', message } }) end)
end

RegisterCommand('oxide:diag', function(source, _args, _raw)
    if not isAuthorized(source) then
        reply(source, '^1[oxide:diag]^7 You do not have permission.', 'error')
        return
    end

    local snapshot = buildSnapshot()
    local path = writeSnapshot(snapshot)

    local real, fallback = 0, 0
    for _, info in pairs(snapshot.olink.namespaces) do
        if info.kind == 'real' then
            real = real + 1
        elseif info.kind == 'fallback' then
            fallback = fallback + 1
        end
    end

    if GetResourceState('oxide-logger') == 'started' then
        pcall(function()
            olink.logger.Info(RESOURCE, 'diag', 'snapshot generated', {
                framework      = snapshot.framework,
                olinkVersion   = snapshot.olink.version,
                namespacesReal = real,
                namespacesStub = fallback,
                resourceCount  = snapshot.resource_counts.total,
                snapshotFile   = path and (RESOURCE .. '/' .. path) or nil,
                triggeredBy    = source,
            })
        end)
    end

    if path then
        print(('^2[oxide:diag]^7 snapshot written to %s/%s (%d resources, %d namespaces real / %d fallback)^0')
            :format(RESOURCE, path, snapshot.resource_counts.total, real, fallback))
    end

    if source ~= 0 then
        reply(source, path
            and ('^2[oxide:diag]^7 snapshot written to %s/%s'):format(RESOURCE, path)
            or '^1[oxide:diag]^7 snapshot write failed (see server console)',
            path and 'success' or 'error')
    end
end, false)

TriggerEvent('chat:addSuggestion', '/oxide:diag', 'Write a support diagnostic snapshot to o-link/diag/')
