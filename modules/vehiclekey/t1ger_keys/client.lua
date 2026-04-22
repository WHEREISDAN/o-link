if not olink._guardImpl('VehicleKey', 't1ger_keys', 't1ger_keys') then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('oxide-vehicles') == 'started' then return end

olink._register('vehiclekey', {
    ---@return string
    GetResourceName = function()
        return 't1ger_keys'
    end,

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
