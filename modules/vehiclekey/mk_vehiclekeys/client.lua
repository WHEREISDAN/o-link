if GetResourceState('oxide-vehicles') == 'started' then return end
if GetResourceState('mk_vehiclekeys') == 'missing' then return end

olink._register('vehiclekey', {
    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Give = function(vehicle, plate)
        if not vehicle or not DoesEntityExist(vehicle) then return end
        exports['mk_vehiclekeys']:AddKey(vehicle)
    end,

    ---@param vehicle number Entity handle
    ---@param plate string|nil
    Remove = function(vehicle, plate)
        if not vehicle or not DoesEntityExist(vehicle) then return end
        exports['mk_vehiclekeys']:RemoveKey(vehicle)
    end,
})
