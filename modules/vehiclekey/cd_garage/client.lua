if GetResourceState('oxide-vehicles') == 'started' then return end
if GetResourceState('cd_garage') == 'missing' then return end

olink._register('vehiclekey', {
    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Give = function(vehicle, plate)
        if not vehicle or not DoesEntityExist(vehicle) then return end
        plate = plate or GetVehicleNumberPlateText(vehicle)
        TriggerEvent('cd_garage:AddKeys', plate)
    end,

    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Remove = function(vehicle, plate)
        -- cd_garage does not support removing keys
    end,
})
