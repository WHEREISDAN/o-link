if GetResourceState('sleepless_interact') ~= 'started' then return end
if GetResourceState('ox_target') == 'started' then return end

local sleepless = exports.sleepless_interact
local targetZones = {}

---Normalize options to match sleepless_interact's expected format
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
        local id = sleepless:addCoords({
            coords  = coords,
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
        local id = sleepless:addSphereZone({
            coords  = coords,
            radius  = radius,
            name    = name,
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
            sleepless:removeCoords(id)
            targetZones[name] = nil
        end
    end,

    ---@param entity number|number[]
    ---@param options table
    AddLocalEntity = function(entity, options)
        options = FixOptions(options or {})
        sleepless:addLocalEntity(entity, options)
    end,

    ---@param entity number|number[]
    ---@param optionNames string|string[]|nil
    RemoveLocalEntity = function(entity, optionNames)
        sleepless:removeLocalEntity(entity, optionNames)
    end,

    ---@param models number|number[]
    ---@param options table
    AddModel = function(models, options)
        options = FixOptions(options or {})
        sleepless:addModel(models, options)
    end,
})
