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

local function handleResponse(registry, name, callbackId, ...)
    local data = registry[callbackId]
    if not data then return end

    if data.callback then
        data.callback(...)
    end

    if data.promise then
        data.promise:resolve({ ... })
    end

    registry[callbackId] = nil
end

if IsDuplicityVersion() then
    -- ================================================================
    -- Server
    -- ================================================================

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
            local result = Citizen.Await(p)
            local returnResults = (result and type(result) == 'table') and result or { result }
            return table.unpack(returnResults)
        end
    end

    RegisterNetEvent(EVENT_NAMES.CLIENT_TO_SERVER, function(name, callbackId, ...)
        if not name or not callbackId then return end

        local handler = ServerCallbacks[name]
        if not handler then return end

        local playerId = source
        if not playerId or playerId == 0 then return end

        local result = table.pack(handler(playerId, ...))
        TriggerClientEvent(EVENT_NAMES.CLIENT_RESPONSE, playerId, name, callbackId, table.unpack(result))
    end)

    RegisterNetEvent(EVENT_NAMES.SERVER_RESPONSE, function(name, callbackId, ...)
        local data = CallbackRegistry[callbackId]
        if not data then return end
        if data.target and data.target ~= source then return end
        handleResponse(CallbackRegistry, name, callbackId, ...)
    end)

else
    -- ================================================================
    -- Client
    -- ================================================================

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
            local result = Citizen.Await(p)
            return table.unpack(result)
        end
    end

    RegisterNetEvent(EVENT_NAMES.CLIENT_RESPONSE, function(name, callbackId, ...)
        handleResponse(CallbackRegistry, name, callbackId, ...)
    end)

    RegisterNetEvent(EVENT_NAMES.SERVER_TO_CLIENT, function(name, callbackId, ...)
        local handler = ClientCallbacks[name]
        if not handler then return end

        local result = table.pack(handler(...))
        TriggerServerEvent(EVENT_NAMES.SERVER_RESPONSE, name, callbackId, table.unpack(result))
    end)
end

-- Self-register when loaded as a shared_script
olink._register('callback', Callback)

return Callback
