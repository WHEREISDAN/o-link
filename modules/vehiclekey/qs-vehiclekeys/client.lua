if not olink._guardImpl('VehicleKey', 'qs-vehiclekeys', 'qs-vehiclekeys') then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('oxide-vehicles') == 'started' then return end

olink._register('vehiclekey', {
    ---@return string
    GetResourceName = function()
        return 'qs-vehiclekeys'
    end,

    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Give = function(vehicle, plate)
        if not vehicle or not DoesEntityExist(vehicle) then return end
        plate = plate or GetVehicleNumberPlateText(vehicle)
        local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        exports['qs-vehiclekeys']:GiveKeys(plate, model, true)
    end,

    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Remove = function(vehicle, plate)
        if not vehicle or not DoesEntityExist(vehicle) then return end
        plate = plate or GetVehicleNumberPlateText(vehicle)
        local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        exports['qs-vehiclekeys']:RemoveKeys(plate, model)
    end,
})
