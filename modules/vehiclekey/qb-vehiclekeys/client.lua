if not olink._guardImpl('VehicleKey', 'qb-vehiclekeys', 'qb-vehiclekeys') then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('oxide-vehicles') == 'started' then return end

olink._register('vehiclekey', {
    ---@return string
    GetResourceName = function()
        return 'qb-vehiclekeys'
    end,

    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Give = function(vehicle, plate)
        if not vehicle or not DoesEntityExist(vehicle) then return end
        plate = plate or GetVehicleNumberPlateText(vehicle)
        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
    end,

    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Remove = function(vehicle, plate)
        if not vehicle or not DoesEntityExist(vehicle) then return end
        plate = plate or GetVehicleNumberPlateText(vehicle)
        TriggerEvent('qb-vehiclekeys:client:RemoveKeys', plate)
    end,
})
