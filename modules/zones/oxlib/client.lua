--- ox_lib zone wrapper for o-link.
--- Provides box, sphere, and poly zone creation/destruction with automatic
--- unique ID generation and resource ownership tracking.
---
---@class ZoneData
---@field id string Unique id for the zone (generated)
---@field invoking string Resource that created the zone
---@field coords vector3? Center coordinates (box/sphere)
---@field points vector2[]? Array of points for poly zones
---@field radius number? Radius for sphere zones
---@field size table? Size table or vec3 for box zones
---@field zone any Internal zone handle returned by lib.zones
---@field debug boolean? Debug flag passed to lib.zones
---@field onEnter fun(data:ZoneData)? Callback invoked on enter (receives ZoneData)
---@field onExit fun(data:ZoneData)? Callback invoked on exit (receives ZoneData)
---@alias ZoneType "box"|"sphere"|"poly"

if GetResourceState('ox_lib') == 'missing' then return end

local allZones = {}
local zoneCounter = 0

local function createUniqueId()
    repeat
        zoneCounter = zoneCounter + 1
    until not allZones[('zone_%d'):format(zoneCounter)]
    return ('zone_%d'):format(zoneCounter)
end

olink._register('zones', {
    ---@type table<string, ZoneData>
    All = allZones,

    --- Create a zone of the specified type.
    ---@param type ZoneType
    ---@param data ZoneData
    ---@return string|nil id Returns the generated zone id on success, or nil on failure
    Create = function(type, data)
        assert(type, "Requires zone type ('box', 'sphere', or 'poly')")
        assert(data, 'Requires data table')
        data.id = createUniqueId()
        data.invoking = GetInvokingResource() or 'unknown'

        local onEnter = data.onEnter or data.OnEnter
        local onExit = data.onExit or data.OnExit

        if type == 'box' then
            assert(data.coords, 'Requires .coords as vector3 in data')
            local width = (data.size and data.size.x) or data.length or 1.0
            local height = (data.size and data.size.y) or data.width or 1.0
            local z = (data.size and data.size.z) or data.height or 1.0
            local zone = lib.zones.box({
                coords = data.coords,
                size = vec3(width, height, z),
                rotation = data.heading or data.rotation or 0.0,
                debug = data.debug or false,
                onEnter = function(point)
                    if onEnter then onEnter(data) end
                end,
                onExit = function(point)
                    if onExit then onExit(data) end
                end,
            })
            data.zone = zone
            allZones[data.id] = data
            return data.id

        elseif type == 'sphere' then
            assert(data.coords, 'Requires .coords as vector3 in data')
            data.radius = data.radius or (data.size and data.size.x) or 1
            local zone = lib.zones.sphere({
                coords = data.coords,
                radius = data.radius,
                debug = data.debug or false,
                onEnter = function(point)
                    data.zone = data.zone or point
                    if onEnter then onEnter(data) end
                end,
                onExit = function(point)
                    data.zone = data.zone or point
                    if onExit then onExit(data) end
                end,
            })
            data.zone = zone
            allZones[data.id] = data
            return data.id

        elseif type == 'poly' then
            assert(data.points, 'Requires an array of vector2 in .points')
            assert(#data.points > 2, 'Requires at least three points in .points')
            local zSize = data.minZ or (data.size and data.size.z) or data.height or data.thickness or 2
            local polyZone = lib.zones.poly({
                points = data.points,
                thickness = zSize,
                debug = data.debug or false,
                onEnter = function(point)
                    data.zone = data.zone or point
                    if onEnter then onEnter(data) end
                end,
                onExit = function(point)
                    data.zone = data.zone or point
                    if onExit then onExit(data) end
                end,
            })
            data.zone = polyZone
            allZones[data.id] = data
            return data.id
        end

        return nil
    end,

    --- Destroy a zone by id.
    ---@param id string
    ---@return boolean
    Destroy = function(id)
        if not id then return false end
        local entry = allZones[id]
        if not entry or not entry.zone then return false end
        entry.zone:remove()
        allZones[id] = nil
        return true
    end,

    --- Destroy all zones created by a specific resource.
    ---@param resource string
    ---@return boolean
    DestroyByResource = function(resource)
        if not resource then return false end
        for id, zone in pairs(allZones) do
            if zone.invoking == resource then
                zone.zone:remove()
                allZones[id] = nil
            end
        end
        return true
    end,

    --- Retrieve zone data by id.
    ---@param id string
    ---@return ZoneData|nil
    Get = function(id)
        if not id then return nil end
        return allZones[id]
    end,
})

-- Clean up zones when their owning resource stops
AddEventHandler('onResourceStop', function(resource)
    for id, zone in pairs(allZones) do
        if zone.invoking == resource then
            if zone.zone then zone.zone:remove() end
            allZones[id] = nil
        end
    end
end)
