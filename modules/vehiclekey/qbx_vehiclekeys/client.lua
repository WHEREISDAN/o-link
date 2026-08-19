if not olink._guardImpl('VehicleKey', 'qbx_vehiclekeys', 'qbx_vehiclekeys') then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('oxide-vehicles') == 'started' then return end

olink._register('vehiclekey', {
    ---@return string
    GetResourceName = function()
        return 'qbx_vehiclekeys'
    end,

    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Give = function(vehicle, plate)
        if not vehicle or not DoesEntityExist(vehicle) then return end
        -- qbx_vehiclekeys 1.0.3+ rejects the plate-based bridge event unless the
        -- player is within config.distanceToVehicle, so grant via netId server-side.
        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        if netId and netId ~= 0 then
            TriggerServerEvent('o-link:server:vehiclekey:give', netId)
            return
        end
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
