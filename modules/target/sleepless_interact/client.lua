if not olink._guardImpl('Target', 'sleepless_interact', 'sleepless_interact') then return end
if not olink._hasOverride('Target') and GetResourceState('ox_target') == 'started' then return end

local sleepless = exports.sleepless_interact
---Shape: { [name] = { id = <zoneId>, creator = <resourceName> } }
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
    ---@return string
    GetResourceName = function()
        return 'sleepless_interact'
    end,

    ---sleepless_interact doesn't expose a global toggle; no-op by design.
    ---@param bool boolean
    DisableTargeting = function(bool)
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
        local id = sleepless:addCoords({
            coords  = coords,
            options = options,
        })
        targetZones[name] = { id = id, creator = GetInvokingResource() }
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
        targetZones[name] = { id = id, creator = GetInvokingResource() }
        return id
    end,

    ---@param name string
    RemoveZone = function(name)
        if not name then return end
        local entry = targetZones[name]
        if entry then
            sleepless:removeCoords(entry.id)
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

    ---@param options table
    AddGlobalPed = function(options)
        options = FixOptions(options or {})
        sleepless:addGlobalPed(options)
    end,

    ---@param optionNames string[]
    RemoveGlobalPed = function(optionNames)
        sleepless:removeGlobalPed(optionNames)
    end,

    ---sleepless_interact doesn't distinguish player from ped — route to ped APIs.
    ---@param options table
    AddGlobalPlayer = function(options)
        options = FixOptions(options or {})
        sleepless:addGlobalPlayer(options)
    end,

    ---@param optionNames string[]|nil
    RemoveGlobalPlayer = function(optionNames)
        sleepless:removeGlobalPlayer(optionNames)
    end,
})

-- Clean up zones when their creator resource stops so we don't leak options.
AddEventHandler('onClientResourceStop', function(resource)
    for name, entry in pairs(targetZones) do
        if entry.creator == resource then
            sleepless:removeCoords(entry.id)
            targetZones[name] = nil
        end
    end
end)
