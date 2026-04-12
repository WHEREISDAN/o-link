if GetResourceState('oxide-vehicles') == 'started' then return end
if GetResourceState('t1ger_keys') ~= 'started' then return end

olink._register('vehiclekey', {
    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Give = function(vehicle, plate)
        if not vehicle or not DoesEntityExist(vehicle) then return end
        plate = plate or GetVehicleNumberPlateText(vehicle)
        local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        exports['t1ger_keys']:GiveTemporaryKeys(plate, model, '')
    end,

    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Remove = function(vehicle, plate)
        -- t1ger_keys does not support removing keys
    end,
})
