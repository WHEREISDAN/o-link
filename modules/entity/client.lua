local ClientEntity = {
    All = {},
    Invoked = {},
    OnCreates = {},
}

---Generate a unique 8-char alphanumeric ID
---@param tbl table
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

-- ================================================================
-- Entity spawn / despawn
-- ================================================================

---@param entityData table
local function SpawnEntity(entityData)
    if entityData.spawned and DoesEntityExist(entityData.spawned) then return end
    if not entityData.model then return end

    lib.requestModel(entityData.model)
    local model = type(entityData.model) == 'string' and joaat(entityData.model) or entityData.model

    local entity
    local coords = entityData.coords
    local rotation = entityData.rotation or vector3(0.0, 0.0, entityData.heading or 0.0)

    if entityData.entityType == 'object' then
        entity = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
        SetEntityRotation(entity, rotation.x, rotation.y, rotation.z, 2, true)
    elseif entityData.entityType == 'ped' then
        local heading = type(rotation) == 'number' and rotation or rotation.z
        entity = CreatePed(4, model, coords.x, coords.y, coords.z, heading, false, false)
    elseif entityData.entityType == 'vehicle' then
        local heading = type(rotation) == 'number' and rotation or rotation.z
        entity = CreateVehicle(model, coords.x, coords.y, coords.z, heading, false, false)
    end

    SetModelAsNoLongerNeeded(model)

    if not entity then return end

    entityData.spawned = entity

    -- Apply properties
    if entityData.freeze == nil or entityData.freeze then
        FreezeEntityPosition(entity, true)
    end
    if entityData.invincible then
        SetEntityInvincible(entity, true)
    end

    -- Apply targets via olink.target
    if entityData.targets and olink.supports('target.AddLocalEntity') then
        olink.target.AddLocalEntity(entity, entityData.targets)
    end

    -- Apply animation
    if entityData.anim and entityData.anim.dict and entityData.anim.name then
        lib.requestAnimDict(entityData.anim.dict)
        TaskPlayAnim(entity, entityData.anim.dict, entityData.anim.name,
            entityData.anim.blendIn or 8.0, entityData.anim.blendOut or -8.0,
            entityData.anim.duration or -1, entityData.anim.flags or 1,
            entityData.anim.playbackRate or 0.0, false, false, false)
    end

    -- Apply attachment
    if entityData.attach then
        local target = entityData.attach.target
        local targetEntity
        if type(target) == 'string' then
            local other = ClientEntity.All[target]
            targetEntity = other and other.args and other.args.spawned or nil
        elseif type(target) == 'number' then
            local player = GetPlayerFromServerId(target)
            if player and player ~= -1 then
                targetEntity = GetPlayerPed(player)
            end
        end
        if targetEntity and DoesEntityExist(targetEntity) then
            local bone = entityData.attach.bone or 0
            local offset = entityData.attach.offset or vector3(0.0, 0.0, 0.0)
            local rot = entityData.attach.rotation or vector3(0.0, 0.0, 0.0)
            AttachEntityToEntity(entity, targetEntity, GetPedBoneIndex(targetEntity, bone),
                offset.x, offset.y, offset.z, rot.x, rot.y, rot.z,
                true, true, false, true, 1, true)
        end
    end

    if entityData.OnSpawn then
        pcall(entityData.OnSpawn, entityData)
    end
end

---@param entityData table
local function DespawnEntity(entityData)
    if not entityData then return end
    if entityData.OnRemove then
        pcall(entityData.OnRemove, entityData)
    end
    if entityData.spawned and DoesEntityExist(entityData.spawned) then
        -- Remove targets before deleting
        if entityData.targets and olink.supports('target.RemoveLocalEntity') then
            olink.target.RemoveLocalEntity(entityData.spawned)
        end
        SetEntityAsMissionEntity(entityData.spawned, true, true)
        DeleteEntity(entityData.spawned)
    end
    entityData.spawned = nil
end

-- ================================================================
-- Public API
-- ================================================================

---@param entityData table
---@return table
function ClientEntity.Create(entityData)
    entityData.id = entityData.id or GenerateId(ClientEntity.All)
    if ClientEntity.All[entityData.id] then return ClientEntity.All[entityData.id] end

    entityData.rotation = entityData.rotation or vector3(0.0, 0.0, entityData.heading or 0.0)
    entityData.invoked = entityData.invoked or GetInvokingResource() or 'o-link'

    -- Run OnCreate hooks
    for key, handler in pairs(ClientEntity.OnCreates) do
        if entityData[key] ~= nil then
            local ok, result = pcall(handler, entityData)
            if ok and result then
                entityData = result
            end
        end
    end

    -- Use lib.points for proximity-based spawn/despawn
    local spawnDistance = entityData.spawnDistance or 50.0
    local point = lib.points.new(entityData.coords, spawnDistance, { entityId = entityData.id })

    function point:onEnter()
        local data = ClientEntity.All[self.entityId]
        if data and data.args then
            SpawnEntity(data.args)
        end
    end

    function point:onExit()
        local data = ClientEntity.All[self.entityId]
        if data and data.args then
            DespawnEntity(data.args)
        end
    end

    local entry = {
        id = entityData.id,
        point = point,
        args = entityData,
    }

    ClientEntity.All[entityData.id] = entry
    ClientEntity.Invoked[entityData.invoked] = ClientEntity.Invoked[entityData.invoked] or {}
    ClientEntity.Invoked[entityData.invoked][entityData.id] = entry

    -- If player is already inside spawn distance, spawn immediately
    local playerCoords = GetEntityCoords(PlayerPedId())
    if #(playerCoords - entityData.coords) <= spawnDistance then
        SpawnEntity(entityData)
    end

    return entry
end

---@param id string|number
function ClientEntity.Destroy(id)
    local entry = ClientEntity.All[id]
    if not entry then return end

    if entry.point then
        entry.point:remove()
    end

    DespawnEntity(entry.args)
    ClientEntity.All[id] = nil
end

---@param id string|number
---@return table|nil
function ClientEntity.Get(id)
    local entry = ClientEntity.All[id]
    if not entry then return nil end
    return entry.args
end

---@return table
function ClientEntity.GetAll()
    local result = {}
    for id, entry in pairs(ClientEntity.All) do
        result[id] = entry.args
    end
    return result
end

---Register a creation hook that fires when entities with a matching property are created
---@param propertyKey string
---@param handler fun(entityData: table): table|nil
function ClientEntity.SetOnCreate(propertyKey, handler)
    ClientEntity.OnCreates[propertyKey] = handler
end

-- ================================================================
-- Network events from server entity system
-- ================================================================

RegisterNetEvent('o-link:client:entity:create', function(entityData)
    if source ~= 65535 then return end
    ClientEntity.Create(entityData)
end)

RegisterNetEvent('o-link:client:entity:createBulk', function(entities)
    if source ~= 65535 then return end
    for _, entityData in pairs(entities) do
        ClientEntity.Create(entityData)
    end
end)

RegisterNetEvent('o-link:client:entity:destroy', function(id)
    if source ~= 65535 then return end
    ClientEntity.Destroy(id)
end)

RegisterNetEvent('o-link:client:entity:destroyBulk', function(ids)
    if source ~= 65535 then return end
    for _, id in ipairs(ids) do
        ClientEntity.Destroy(id)
    end
end)

RegisterNetEvent('o-link:client:entity:update', function(id, data)
    if source ~= 65535 then return end
    local entry = ClientEntity.All[id]
    if not entry or not entry.args then return end
    for key, value in pairs(data) do
        entry.args[key] = value
    end
end)

-- ================================================================
-- Resource cleanup
-- ================================================================

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for id in pairs(ClientEntity.All) do
            ClientEntity.Destroy(id)
        end
    else
        local invoked = ClientEntity.Invoked[resourceName]
        if invoked then
            for id in pairs(invoked) do
                ClientEntity.Destroy(id)
            end
            ClientEntity.Invoked[resourceName] = nil
        end
    end
end)

olink._register('entity', ClientEntity)
