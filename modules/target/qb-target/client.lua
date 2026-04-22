if not olink._guardImpl('Target', 'qb-target', 'qb-target') then return end
if not olink._hasOverride('Target') and GetResourceState('ox_target') == 'started' then return end

local qb_target = exports['qb-target']
---Track zones per creator resource so we can clean them up on resource stop.
---Shape: { [name] = { creator = <resourceName> } }
local targetZones = {}

---Extract the largest distance value from an options table
---@param options table
---@return number
local function getLargestDistance(options)
    local largest = -1
    for _, v in pairs(options) do
        if v.distance and v.distance > largest then
            largest = v.distance
        end
    end
    return largest ~= -1 and largest or 2.0
end

---Normalize options to match qb-target's expected format
---@param options table
---@return table
local function FixOptions(options)
    for k, v in pairs(options) do
        local action = v.onSelect or v.action
        local wrapped = action and function(entityOrData)
            if type(entityOrData) == 'table' then
                return action(entityOrData.entity)
            end
            return action(entityOrData)
        end
        if v.serverEvent then
            v.type = 'server'
            v.event = v.serverEvent
        elseif v.event then
            v.type = 'client'
        end
        options[k].action = wrapped
        options[k].job = v.job or v.groups
    end
    return options
end

olink._register('target', {
    ---@return string
    GetResourceName = function()
        return 'qb-target'
    end,

    ---qb-target doesn't expose a toggle, so this is a no-op by design.
    ---@param bool boolean
    DisableTargeting = function(bool)
        -- qb-target has no native toggle; callers expect it to be harmless.
    end,

    ---@param name string
    ---@param coords vector3
    ---@param size vector3
    ---@param heading number
    ---@param options table
    ---@param debug boolean|nil
    AddBoxZone = function(name, coords, size, heading, options, debug)
        options = FixOptions(options or {})
        if not next(options) then return end
        qb_target:AddBoxZone(name, coords, size.x, size.y, {
            name       = name,
            debugPoly  = debug or false,
            heading    = heading,
            minZ       = coords.z - (size.z * 0.5),
            maxZ       = coords.z + (size.z * 0.5),
        }, {
            options  = options,
            distance = getLargestDistance(options),
        })
        targetZones[name] = { creator = GetInvokingResource() }
        return name
    end,

    ---@param name string
    ---@param coords vector3
    ---@param radius number
    ---@param options table
    ---@param debug boolean|nil
    AddSphereZone = function(name, coords, radius, options, debug)
        options = FixOptions(options or {})
        qb_target:AddCircleZone(name, coords, radius, {
            name      = name,
            debugPoly = debug or false,
        }, {
            options  = options,
            distance = getLargestDistance(options),
        })
        targetZones[name] = { creator = GetInvokingResource() }
        return name
    end,

    ---@param name string
    RemoveZone = function(name)
        if not name then return end
        if targetZones[name] then
            qb_target:RemoveZone(name)
            targetZones[name] = nil
        end
    end,

    ---@param entity number|number[]
    ---@param options table
    AddLocalEntity = function(entity, options)
        options = FixOptions(options or {})
        qb_target:AddTargetEntity(entity, {
            options  = options,
            distance = getLargestDistance(options),
        })
    end,

    ---@param entity number|number[]
    ---@param optionNames string|string[]|nil
    RemoveLocalEntity = function(entity, optionNames)
        qb_target:RemoveTargetEntity(entity, optionNames)
    end,

    ---@param models number|number[]
    ---@param options table
    AddModel = function(models, options)
        options = FixOptions(options or {})
        qb_target:AddTargetModel(models, {
            options  = options,
            distance = getLargestDistance(options),
        })
    end,

    ---@param options table
    AddGlobalPed = function(options)
        options = FixOptions(options or {})
        qb_target:AddGlobalPed({
            options  = options,
            distance = getLargestDistance(options),
        })
    end,

    ---@param optionNames string[]
    RemoveGlobalPed = function(optionNames)
        qb_target:RemoveGlobalPed(optionNames)
    end,

    ---Attach options to every player ped.
    ---@param options table
    AddGlobalPlayer = function(options)
        options = FixOptions(options or {})
        qb_target:AddGlobalPlayer({
            options  = options,
            distance = getLargestDistance(options),
        })
    end,

    ---Remove options from every player ped.
    ---@param optionNames string[]|nil
    RemoveGlobalPlayer = function(optionNames)
        qb_target:RemoveGlobalPlayer(optionNames)
    end,

    ---@param options table
    AddGlobalVehicle = function(options)
        options = FixOptions(options or {})
        qb_target:AddGlobalVehicle({
            options  = options,
            distance = getLargestDistance(options),
        })
    end,

    ---@param optionNames string[]
    RemoveGlobalVehicle = function(optionNames)
        qb_target:RemoveGlobalVehicle(optionNames)
    end,

    ---@param netId number|number[]
    ---@param options table
    AddNetworkedEntity = function(netId, options)
        options = FixOptions(options or {})
        qb_target:AddTargetEntity(netId, {
            options  = options,
            distance = getLargestDistance(options),
        })
    end,

    ---@param netId number|number[]
    ---@param optionNames string|string[]|nil
    RemoveNetworkedEntity = function(netId, optionNames)
        qb_target:RemoveTargetEntity(netId, optionNames)
    end,
})

-- Clean up zones when their creator resource stops so we don't leak options.
AddEventHandler('onClientResourceStop', function(resource)
    for name, entry in pairs(targetZones) do
        if entry.creator == resource then
            qb_target:RemoveZone(name)
            targetZones[name] = nil
        end
    end
end)
