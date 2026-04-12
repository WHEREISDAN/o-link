--- PolyZone wrapper for o-link.
--- Falls back to PolyZone when ox_lib is not started.
---
---@class ZoneData
---@field id string Unique id for the zone (generated)
---@field invoking string Resource that created the zone
---@field coords vector3? Center coordinates (box/sphere)
---@field points vector2[]? Array of points for poly zones
---@field radius number? Radius for sphere zones
---@field size table? Size table or vec3 for box zones
---@field zone any Internal zone handle
---@field debug boolean? Debug flag
---@field onEnter fun(data:ZoneData)? Callback invoked on enter
---@field onExit fun(data:ZoneData)? Callback invoked on exit
---@alias ZoneType "box"|"sphere"|"poly"

if GetResourceState('PolyZone') == 'missing' then return end
if GetResourceState('ox_lib') == 'started' then return end

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
        local zone = nil

        if type == 'box' then
            assert(data.coords, 'Requires .coords as vector3 in data')
            local width = (data.size and data.size.x) or data.length or 1.0
            local height = (data.size and data.size.y) or data.width or 1.0
            local z = (data.size and data.size.z) or data.height or 1.0
            data.size = vec3(width, height, z)
            data.heading = data.heading or data.rotation
            data.rotation = data.heading
            zone = BoxZone:Create(data.coords, width, height, {
                name = data.id,
                debugPoly = data.debug,
                minZ = data.coords.z - 0.5,
                maxZ = data.coords.z + z - 0.5,
                heading = data.heading or data.rotation,
            })

        elseif type == 'sphere' then
            assert(data.coords, 'Requires .coords as vector3 in data')
            data.radius = data.radius or (data.size and data.size.x) or 1
            zone = CircleZone:Create(data.coords, data.radius, {
                name = data.id,
                debugPoly = data.debug,
            })

        elseif type == 'poly' then
            assert(data.points, 'Requires an array of vector2 in .points')
            assert(#data.points > 2, 'Requires at least three points in .points')
            local zSize = data.minZ or (data.size and data.size.z) or data.height or data.thickness or 2
            local firstPoint = data.points[1]
            local firstZ = firstPoint and firstPoint.z
            zone = PolyZone:Create(data.points, {
                name = data.id,
                debugPoly = data.debug,
                minZ = firstZ and (firstZ - 0.5) or nil,
                maxZ = firstZ and (firstZ + zSize - 0.5) or nil,
            })
        end

        if not zone then return nil end

        data.zone = zone
        zone:onPlayerInOut(function(isInside, _)
            if isInside then
                local cb = data.onEnter or data.OnEnter
                if cb then cb(data) end
            else
                local cb = data.onExit or data.OnExit
                if cb then cb(data) end
            end
        end)

        allZones[data.id] = data
        return data.id
    end,

    --- Destroy a zone by id.
    ---@param id string
    ---@return boolean
    Destroy = function(id)
        if not id then return false end
        local entry = allZones[id]
        if not entry or not entry.zone then return false end
        entry.zone:destroy()
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
                zone.zone:destroy()
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
            if zone.zone then zone.zone:destroy() end
            allZones[id] = nil
        end
    end
end)
