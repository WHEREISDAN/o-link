if not olink._guardImpl('VehicleKey', 'okokGarage', 'okokGarage') then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('oxide-vehicles') == 'started' then return end

olink._register('vehiclekey', {
    ---@return string
    GetResourceName = function()
        return 'okokGarage'
    end,

    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Give = function(vehicle, plate)
        if not vehicle or not DoesEntityExist(vehicle) then return end
        plate = plate or GetVehicleNumberPlateText(vehicle)
        TriggerServerEvent('okokGarage:GiveKeys', plate)
    end,

    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Remove = function(vehicle, plate)
        if not vehicle or not DoesEntityExist(vehicle) then return end
        plate = plate or GetVehicleNumberPlateText(vehicle)
        local src = GetPlayerServerId(PlayerId())
        TriggerServerEvent('okokGarage:RemoveKeys', plate, src)
    end,
})
