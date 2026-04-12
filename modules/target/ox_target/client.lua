if GetResourceState('ox_target') == 'missing' then return end

local ox_target = exports.ox_target
local targetZones = {}

---Process options to normalize onSelect/action handlers and job groups
---@param options table
---@return table
local function FixOptions(options)
    for _, v in pairs(options) do
        local action = v.onSelect or v.action
        if action then
            v.onSelect = function(data)
                if type(data) == 'table' then
                    return action(data.entity)
                end
                return action(data)
            end
        elseif v.type == 'server' then
            v.serverEvent = v.event
            v.event = nil
        end
        v.groups = v.job or v.groups
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
        local id = ox_target:addBoxZone({
            coords = coords,
            size = size,
            rotation = heading,
            debug = debug or false,
            options = options,
        })
        targetZones[name] = id
        return id
    end,

    ---@param name string
    ---@param coords vector3
    ---@param radius number
    ---@param options table
    ---@param debug boolean|nil
    AddSphereZone = function(name, coords, radius, options, debug)
        options = FixOptions(options or {})
        local id = ox_target:addSphereZone({
            coords = coords,
            radius = radius,
            name = name,
            debug = debug or false,
            options = options,
        })
        targetZones[name] = id
        return id
    end,

    ---@param name string
    RemoveZone = function(name)
        if not name then return end
        local id = targetZones[name]
        if id then
            ox_target:removeZone(id)
            targetZones[name] = nil
        end
    end,

    ---@param entity number|number[]
    ---@param options table
    AddLocalEntity = function(entity, options)
        options = FixOptions(options)
        ox_target:addLocalEntity(entity, options)
    end,

    ---@param entity number|number[]
    ---@param optionNames string|string[]|nil
    RemoveLocalEntity = function(entity, optionNames)
        ox_target:removeLocalEntity(entity, optionNames)
    end,

    ---@param models number|number[]
    ---@param options table
    AddModel = function(models, options)
        options = FixOptions(options)
        ox_target:addModel(models, options)
    end,

    ---@param model number
    RemoveModel = function(model)
        ox_target:removeModel(model)
    end,
})
