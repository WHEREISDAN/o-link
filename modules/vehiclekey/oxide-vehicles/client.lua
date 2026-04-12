if GetResourceState('oxide-vehicles') ~= 'started' then return end

olink._register('vehiclekey', {
    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Give = function(vehicle, plate)
        if not vehicle or not DoesEntityExist(vehicle) then return end
        plate = plate or GetVehicleNumberPlateText(vehicle)
        local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        TriggerServerEvent('oxide:vehicles:bridgeGiveKeys', netId, plate, model)
    end,

    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Remove = function(vehicle, plate)
        if not vehicle or not DoesEntityExist(vehicle) then return end
        plate = plate or GetVehicleNumberPlateText(vehicle)
        TriggerServerEvent('oxide:vehicles:bridgeRemoveKeys', plate)
    end,
})
