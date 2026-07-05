if not olink._guardImpl('Target', 'tgiann-target', 'tgiann-target') then return end
-- oxide-target is the first-party fork; its native adapter wins if both are present.
if not olink._hasOverride('Target') and GetResourceState('oxide-target') == 'started' then return end

local tgiann = exports['tgiann-target']
---Track zones per creator resource so we can clean them up on resource stop.
---Shape: { [name] = { id = <zoneId>, creator = <resourceName> } }
local targetZones = {}

---Check a group filter (job/gang name, array of names, or name -> minimum rank
---hash) against the bridge's own job/gang data.
---@param filter string|table
---@return boolean
local function hasGroup(filter)
    local ok, job = pcall(function() return olink.job and olink.job.Get() end)
    if not ok then job = nil end
    local okGang, gang = pcall(function() return olink.gang and olink.gang.Get() end)
    if not okGang then gang = nil end

    local ftype = type(filter)
    if ftype == 'string' then
        return (job and job.name == filter) or (gang and gang.name == filter) or false
    end
    if ftype ~= 'table' then return true end

    if table.type(filter) == 'hash' then
        for name, minRank in pairs(filter) do
            minRank = tonumber(minRank) or 0
            if job and job.name == name and (job.rank or 0) >= minRank then return true end
            if gang and gang.name == name and (gang.rank or 0) >= minRank then return true end
        end
    else
        for i = 1, #filter do
            local name = filter[i]
            if (job and job.name == name) or (gang and gang.name == name) then return true end
        end
    end
    return false
end

---Process options to normalize onSelect/action handlers and enforce group
---restrictions bridge-side. Group filters are folded into canInteract (which
---tgiann-target pcalls) instead of being passed through as option.groups:
---tgiann's qb framework layer indexes playerData.job unguarded inside its
---un-pcalled scan loop, so one groups-gated option crashes all targeting
---whenever player data isn't loaded yet.
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

        local groups = v.job or v.groups
        if groups then
            v.job, v.groups, v.gang = nil, nil, nil
            local innerCanInteract = v.canInteract
            v.canInteract = function(...)
                if not hasGroup(groups) then return false end
                if innerCanInteract then return innerCanInteract(...) end
                return true
            end
        end
    end
    return options
end

olink._register('target', {
    ---@return string
    GetResourceName = function()
        return 'tgiann-target'
    end,

    ---Toggle the targeting system on or off for this player.
    ---@param bool boolean
    DisableTargeting = function(bool)
        tgiann:disableTargeting(bool)
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
        local id = tgiann:addBoxZone({
            name = name,
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
        local id = tgiann:addSphereZone({
            name = name,
            coords = coords,
            radius = radius,
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
            tgiann:removeZone(entry.id)
            targetZones[name] = nil
        end
    end,

    ---@param entity number|number[]
    ---@param options table
    AddLocalEntity = function(entity, options)
        options = FixOptions(options)
        tgiann:addLocalEntity(entity, options)
    end,

    ---@param entity number|number[]
    ---@param optionNames string|string[]|nil
    RemoveLocalEntity = function(entity, optionNames)
        tgiann:removeLocalEntity(entity, optionNames)
    end,

    ---@param models number|number[]
    ---@param options table
    AddModel = function(models, options)
        options = FixOptions(options)
        tgiann:addModel(models, options)
    end,

    ---@param model number
    RemoveModel = function(model)
        tgiann:removeModel(model)
    end,

    ---Attach options to every player ped.
    ---@param options table
    AddGlobalPlayer = function(options)
        options = FixOptions(options)
        tgiann:addGlobalPlayer(options)
    end,

    ---Remove options from every player ped.
    ---@param optionNames string|string[]|nil
    RemoveGlobalPlayer = function(optionNames)
        tgiann:removeGlobalPlayer(optionNames)
    end,

    ---@param options table
    AddGlobalPed = function(options)
        options = FixOptions(options)
        tgiann:addGlobalPed(options)
    end,

    ---@param optionNames string[]
    RemoveGlobalPed = function(optionNames)
        tgiann:removeGlobalPed(optionNames)
    end,

    ---@param options table
    AddGlobalVehicle = function(options)
        options = FixOptions(options)
        tgiann:addGlobalVehicle(options)
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
            tgiann:removeGlobalVehicle(names)
        else
            tgiann:removeGlobalVehicle(options)
        end
    end,

    ---@param netId number|number[]
    ---@param options table
    AddNetworkedEntity = function(netId, options)
        options = FixOptions(options)
        tgiann:addEntity(netId, options)
    end,

    ---@param netId number|number[]
    ---@param optionNames string|string[]|nil
    RemoveNetworkedEntity = function(netId, optionNames)
        tgiann:removeEntity(netId, optionNames)
    end,
})

-- Clean up zones when their creator resource stops so we don't leak options.
AddEventHandler('onClientResourceStop', function(resource)
    for name, entry in pairs(targetZones) do
        if entry.creator == resource then
            tgiann:removeZone(entry.id, true)
            targetZones[name] = nil
        end
    end
end)
