-- Adapter for oxide-vehicles (vehiclekey, client). Registers IMMEDIATELY so
-- consumers that snapshot olink across the resource boundary capture real
-- wrapper refs, not stubs.

local RESOURCE = 'oxide-vehicles'

-- Pure adapter: bail if oxide-vehicles isn't installed.
if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('VehicleKey', RESOURCE, false) then return end

local function isStarted()
    return GetResourceState(RESOURCE) == 'started'
end

olink._register('vehiclekey', {
    ---@return string
    GetResourceName = function() return RESOURCE end,

    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Give = function(vehicle, plate)
        if not vehicle or not DoesEntityExist(vehicle) then return end
        if not isStarted() then return end
        plate = plate or GetVehicleNumberPlateText(vehicle)
        local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        TriggerServerEvent('oxide:vehicles:bridgeGiveKeys', netId, plate, model)
    end,

    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Remove = function(vehicle, plate)
        if not vehicle or not DoesEntityExist(vehicle) then return end
        if not isStarted() then return end
        plate = plate or GetVehicleNumberPlateText(vehicle)
        TriggerServerEvent('oxide:vehicles:bridgeRemoveKeys', plate)
    end,
}, RESOURCE)
