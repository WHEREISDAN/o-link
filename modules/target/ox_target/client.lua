if not olink._guardImpl('Target', 'ox_target', 'ox_target') then return end

local ox_target = exports.ox_target
---Track zones per creator resource so we can clean them up on resource stop.
---Shape: { [name] = { id = <zoneId>, creator = <resourceName> } }
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
    ---@return string
    GetResourceName = function()
        return 'ox_target'
    end,

    ---Toggle the targeting system on or off for this player.
    ---@param bool boolean
    DisableTargeting = function(bool)
        ox_target:disableTargeting(bool)
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
        local id = ox_target:addBoxZone({
            coords = coords,
            size = size,
            rotation = heading,
            debug = debug or false,
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
        local id = ox_target:addSphereZone({
            coords = coords,
            radius = radius,
            name = name,
            debug = debug or false,
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
            ox_target:removeZone(entry.id)
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

    ---Attach options to every player ped.
    ---@param options table
    AddGlobalPlayer = function(options)
        options = FixOptions(options)
        ox_target:addGlobalPlayer(options)
    end,

    ---Remove options from every player ped.
    RemoveGlobalPlayer = function()
        ox_target:removeGlobalPlayer()
    end,

    ---@param options table
    AddGlobalPed = function(options)
        options = FixOptions(options)
        ox_target:addGlobalPed(options)
    end,

    ---@param optionNames string[]
    RemoveGlobalPed = function(optionNames)
        ox_target:removeGlobalPed(optionNames)
    end,

    ---@param options table
    AddGlobalVehicle = function(options)
        options = FixOptions(options)
        ox_target:addGlobalVehicle(options)
    end,

    ---Remove options from every vehicle. Accepts either an options table
    ---(names extracted internally) or a raw name list.
    ---@param options table|string[]
    RemoveGlobalVehicle = function(options)
        if type(options) == 'table' and options[1] and type(options[1]) == 'table' then
            local names = {}
            for _, v in pairs(options) do
                if v.name then names[#names + 1] = v.name end
            end
            ox_target:removeGlobalVehicle(names)
        else
            ox_target:removeGlobalVehicle(options)
        end
    end,

    ---@param netId number|number[]
    ---@param options table
    AddNetworkedEntity = function(netId, options)
        options = FixOptions(options)
        ox_target:addEntity(netId, options)
    end,

    ---@param netId number|number[]
    ---@param optionNames string|string[]|nil
    RemoveNetworkedEntity = function(netId, optionNames)
        ox_target:removeEntity(netId, optionNames)
    end,
})

-- Clean up zones when their creator resource stops so we don't leak options.
AddEventHandler('onClientResourceStop', function(resource)
    for name, entry in pairs(targetZones) do
        if entry.creator == resource then
            ox_target:removeZone(entry.id)
            targetZones[name] = nil
        end
    end
end)
