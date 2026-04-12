if GetResourceState('oxide-vehicles') == 'started' then return end
if GetResourceState('qbx_vehiclekeys') ~= 'started' then return end

olink._register('vehiclekey', {
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
