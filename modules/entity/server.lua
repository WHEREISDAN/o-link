local Entities = {}
local Invoked = {} -- { [resourceName] = { [entityId] = entityData } }

---Generate a unique 8-char alphanumeric ID
---@param tbl table Table of existing IDs (keys)
---@return string
local function GenerateId(tbl)
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local id
    repeat
        id = ''
        for _ = 1, 8 do
            local i = math.random(1, #chars)
            id = id .. chars:sub(i, i)
        end
    until not tbl[id]
    return id
end

local ServerEntity = {}

---@param data table { id?, entityType, model, coords, rotation?, heading?, ... }
---@return table EntityRecord
function ServerEntity.Create(data)
    local id = data.id or GenerateId(Entities)
    data.id = id
    data.rotation = data.rotation or vector3(0.0, 0.0, data.heading or 0.0)

    local invoking = GetInvokingResource() or 'o-link'
    data.invoked = invoking
    Invoked[invoking] = Invoked[invoking] or {}
    Invoked[invoking][id] = data

    Entities[id] = data
    TriggerClientEvent('o-link:client:entity:create', -1, data)
    return data
end

---@param id string|number
function ServerEntity.Destroy(id)
    local entity = Entities[id]
    if not entity then return end

    -- Clean up Invoked tracking
    if entity.invoked and Invoked[entity.invoked] then
        Invoked[entity.invoked][id] = nil
    end

    Entities[id] = nil
    TriggerClientEvent('o-link:client:entity:destroy', -1, id)
end

---@param id string|number
---@return table|nil
function ServerEntity.Get(id)
    return Entities[id]
end

---@param id string|number
---@param data table Fields to update
---@return boolean
function ServerEntity.Set(id, data)
    local entity = Entities[id]
    if not entity then return false end
    for key, value in pairs(data) do
        entity[key] = value
    end
    TriggerClientEvent('o-link:client:entity:update', -1, id, data)
    return true
end

-- Clean up entities when the invoking resource stops
AddEventHandler('onResourceStop', function(resourceName)
    local invoked = Invoked[resourceName]
    if not invoked then return end
    local ids = {}
    for id in pairs(invoked) do
        Entities[id] = nil
        ids[#ids + 1] = id
    end
    if #ids > 0 then
        TriggerClientEvent('o-link:client:entity:destroyBulk', -1, ids)
    end
    Invoked[resourceName] = nil
end)

-- When a player loads in, send them all existing entities
AddEventHandler('olink:server:playerReady', function(src)
    if next(Entities) then
        TriggerClientEvent('o-link:client:entity:createBulk', src, Entities)
    end
end)

olink._register('entity', ServerEntity)
