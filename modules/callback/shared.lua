local Callback = {}
local CallbackRegistry = {}

local RESOURCE = 'o-link'
local EVENT_NAMES = {
    CLIENT_TO_SERVER  = RESOURCE .. ':CS:Callback',
    SERVER_TO_CLIENT  = RESOURCE .. ':SC:Callback',
    CLIENT_RESPONSE   = RESOURCE .. ':CSR:Callback',
    SERVER_RESPONSE   = RESOURCE .. ':SCR:Callback',
}

local function generateCallbackId(name)
    return ('%s_%d'):format(name, math.random(1000000, 9999999))
end

-- Backstop for awaited triggers (both directions): if the response is lost
-- (o-link restarted mid-flight, event dropped, receiver gone), resolve nil
-- instead of blocking the caller's thread forever. Callback-style triggers are
-- exempt — they may legitimately wait on user input (e.g. notify.Confirm) far
-- longer than this.
local AWAIT_TIMEOUT_MS = 30000

local function armAwaitTimeout(registry, name, callbackId)
    SetTimeout(AWAIT_TIMEOUT_MS, function()
        local data = registry[callbackId]
        if not data then return end
        registry[callbackId] = nil
        print(('[o-link] callback \'%s\' got no response within %dms'):format(name, AWAIT_TIMEOUT_MS))
        if data.promise then data.promise:resolve(nil) end
    end)
end

local function handleResponse(registry, name, callbackId, ...)
    local data = registry[callbackId]
    if not data then return end

    if data.callback then
        data.callback(...)
    end

    if data.promise then
        -- Use table.pack so trailing nils and `nil, err` returns survive.
        data.promise:resolve(table.pack(...))
    end

    registry[callbackId] = nil
end

if IsDuplicityVersion() then
    local ServerCallbacks = {}

    function Callback.Register(name, handler)
        ServerCallbacks[name] = handler
    end

    function Callback.Trigger(name, target, ...)
        local args = { ... }
        local callback = type(args[1]) == 'function' and table.remove(args, 1) or nil

        local callbackId = generateCallbackId(name)
        local p = promise.new()

        CallbackRegistry[callbackId] = {
            callback = callback,
            promise = p,
            target = type(target) ~= 'table' and tonumber(target) or nil,
        }

        if type(target) == 'table' then
            for _, id in ipairs(target) do
                TriggerClientEvent(EVENT_NAMES.SERVER_TO_CLIENT, tonumber(id), name, callbackId, table.unpack(args))
            end
        else
            TriggerClientEvent(EVENT_NAMES.SERVER_TO_CLIENT, tonumber(target), name, callbackId, table.unpack(args))
        end

        if not callback then
            armAwaitTimeout(CallbackRegistry, name, callbackId)
            local result = Citizen.Await(p)
            if type(result) ~= 'table' then return result end
            return table.unpack(result, 1, result.n or #result)
        end
    end

    -- A dropped player can never answer: resolve their in-flight triggers nil so
    -- awaiting server threads unblock and the registry entries don't leak.
    -- Multi-target triggers (target == nil) are covered by the await timeout.
    AddEventHandler('playerDropped', function()
        local src = source
        for callbackId, data in pairs(CallbackRegistry) do
            if data.target == src then
                CallbackRegistry[callbackId] = nil
                if data.promise then data.promise:resolve(table.pack()) end
                if data.callback then data.callback() end
            end
        end
    end)

    RegisterNetEvent(EVENT_NAMES.CLIENT_TO_SERVER, function(name, callbackId, ...)
        if not name or not callbackId then return end

        local playerId = source
        if not playerId or playerId == 0 then return end

        -- Always answer, even on error or unknown name — an unanswered awaited
        -- Trigger blocks the caller's thread forever (frozen spawn flows, stuck
        -- cameras on the client).
        local handler = ServerCallbacks[name]
        if not handler then
            TriggerClientEvent(EVENT_NAMES.CLIENT_RESPONSE, playerId, name, callbackId)
            return
        end

        local ok, result = pcall(function(...)
            return table.pack(handler(playerId, ...))
        end, ...)

        if not ok then
            print(('[o-link] server callback \'%s\' errored: %s'):format(name, result))
            result = table.pack()
        end

        TriggerClientEvent(EVENT_NAMES.CLIENT_RESPONSE, playerId, name, callbackId, table.unpack(result, 1, result.n))
    end)

    RegisterNetEvent(EVENT_NAMES.SERVER_RESPONSE, function(name, callbackId, ...)
        local data = CallbackRegistry[callbackId]
        if not data then return end
        if data.target and data.target ~= source then return end
        handleResponse(CallbackRegistry, name, callbackId, ...)
    end)

else
    local ClientCallbacks = {}

    function Callback.Register(name, handler)
        ClientCallbacks[name] = handler
    end

    function Callback.Trigger(name, ...)
        local args = { ... }
        local callback = type(args[1]) == 'function' and table.remove(args, 1) or nil

        local callbackId = generateCallbackId(name)
        local p = promise.new()

        CallbackRegistry[callbackId] = {
            callback = callback,
            promise = p,
        }

        TriggerServerEvent(EVENT_NAMES.CLIENT_TO_SERVER, name, callbackId, table.unpack(args))

        if not callback then
            armAwaitTimeout(CallbackRegistry, name, callbackId)
            local result = Citizen.Await(p)
            if type(result) ~= 'table' then return result end
            return table.unpack(result, 1, result.n or #result)
        end
    end

    RegisterNetEvent(EVENT_NAMES.CLIENT_RESPONSE, function(name, callbackId, ...)
        handleResponse(CallbackRegistry, name, callbackId, ...)
    end)

    RegisterNetEvent(EVENT_NAMES.SERVER_TO_CLIENT, function(name, callbackId, ...)
        -- Always answer, even on error or unknown name — an unanswered awaited
        -- Trigger blocks the server-side caller forever.
        local handler = ClientCallbacks[name]
        if not handler then
            TriggerServerEvent(EVENT_NAMES.SERVER_RESPONSE, name, callbackId)
            return
        end

        local ok, result = pcall(function(...)
            return table.pack(handler(...))
        end, ...)

        if not ok then
            print(('[o-link] client callback \'%s\' errored: %s'):format(name, result))
            result = table.pack()
        end

        TriggerServerEvent(EVENT_NAMES.SERVER_RESPONSE, name, callbackId, table.unpack(result, 1, result.n))
    end)
end

-- Self-register when loaded as a shared_script
olink._register('callback', Callback)

return Callback
