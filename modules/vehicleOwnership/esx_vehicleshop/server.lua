if GetResourceState('es_extended') ~= 'started' then return end

olink._register('vehicleOwnership', {
    ---@return string
    GetResourceName = function()
        return 'es_extended'
    end,

    ---Transfers vehicle ownership by plate to a new owner (ESX identifier).
    ---Uses direct SQL since ESX's class method requires the vehicle to be spawned.
    ---@param plate string The vehicle's license plate
    ---@param newOwnerIdentifier string The new owner's ESX identifier
    ---@return boolean success
    TransferOwnership = function(plate, newOwnerIdentifier)
        assert(type(plate) == "string", "Expected 'plate' to be a string")
        assert(type(newOwnerIdentifier) == "string", "Expected 'newOwnerIdentifier' to be a string (identifier)")

        local affectedRows = MySQL.update.await(
            'UPDATE owned_vehicles SET owner = ? WHERE plate = ?',
            { newOwnerIdentifier, plate }
        )

        return affectedRows and affectedRows > 0
    end,
})
