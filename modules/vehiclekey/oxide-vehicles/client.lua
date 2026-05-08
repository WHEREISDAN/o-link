local RESOURCE = 'oxide-vehicles'

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
        Entity(vehicle).state:set('oxide:plate', plate, true)
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
