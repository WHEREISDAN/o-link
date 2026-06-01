-- ESX housing provider (esx_property). esx_property has no free/starter property
-- concept, so CreateStartingApartment is unsupported (returns false) and new ESX
-- characters spawn at a preset. Listing/entering owned properties is supported;
-- esx_property indexes properties by their position in the runtime Properties
-- array, so that index is the id used by esx_property:enter.

local RESOURCE = 'esx_property'

if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Housing', RESOURCE, false) then return end

local function isStarted() return GetResourceState(RESOURCE) == 'started' end

-- Presence relay: mirror interior enter/leave into the housing relay.
RegisterNetEvent('esx_property:enter', function(insideId)
    TriggerEvent('o-link:server:OnPlayerInside', source, insideId)
end)
RegisterNetEvent('esx_property:leave', function(insideId)
    TriggerEvent('o-link:server:OnPlayerInside', source, insideId)
end)

local function getIdentifier(src)
    local ok, ESX = pcall(function() return exports.es_extended:getSharedObject() end)
    if not ok or not ESX then return nil end
    local xPlayer = ESX.GetPlayerFromId(src)
    return xPlayer and xPlayer.identifier or nil
end

local function getProperties()
    local ok, props = pcall(function() return exports.esx_property:GetProperties() end)
    if ok and type(props) == 'table' then return props end
    return {}
end

olink._register('housing', {
    GetResourceName = function() return RESOURCE end,

    -- No starter/free property in esx_property.
    CreateStartingApartment = function() return false end,

    GetOwnedProperties = function(src, ownerId)
        if not isStarted() then return {} end
        local identifier = ownerId or getIdentifier(src)
        if not identifier then return {} end
        local props = getProperties()
        local out = {}
        for i = 1, #props do
            local p = props[i]
            if p.Owned and p.Owner == identifier then
                local entry = { id = i, kind = 'property', label = p.Name }
                local e = p.Entrance
                if type(e) == 'table' and e.x then
                    entry.coords = { x = e.x, y = e.y, z = e.z }
                end
                out[#out + 1] = entry
            end
        end
        return out
    end,

    SpawnInside = function(src, id)
        if not isStarted() then return false end
        id = tonumber(id)
        if not id then return false end
        local identifier = getIdentifier(src)
        if not identifier then return false end
        local p = getProperties()[id]
        if not p or not p.Owned or p.Owner ~= identifier then return false end
        TriggerClientEvent('o-link:housing:esx:enter', src, id)
        return true
    end,
})
