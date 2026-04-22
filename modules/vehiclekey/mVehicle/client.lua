if not olink._guardImpl('VehicleKey', 'mVehicle', 'mVehicle') then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('oxide-vehicles') == 'started' then return end

olink._register('vehiclekey', {
    ---@return string
    GetResourceName = function()
        return 'mVehicle'
    end,

    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Give = function(vehicle, plate)
        if not vehicle or not DoesEntityExist(vehicle) then return end
        exports.mVehicle:AddTemporalVehicleClient(vehicle)
    end,

    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Remove = function(vehicle, plate)
        -- mVehicle does not support removing keys
    end,
})
