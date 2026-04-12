if GetResourceState('qb-target') == 'missing' then return end
if GetResourceState('ox_target') == 'started' then return end

local qb_target = exports['qb-target']
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
        targetZones[name] = true
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
        targetZones[name] = true
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
})
