if GetResourceState('qb-garages') == 'missing' then return end

olink._register('vehicleOwnership', {
    ---@return string
    GetResourceName = function()
        return 'qb-garages'
    end,

    ---Transfers vehicle ownership by plate to a new owner (citizenid).
    ---Uses direct SQL since QBCore has no transfer ownership export.
    ---Updates both citizenid and license atomically.
    ---@param plate string The vehicle's license plate
    ---@param newOwnerIdentifier string The new owner's citizenid
    ---@return boolean success
    TransferOwnership = function(plate, newOwnerIdentifier)
        assert(type(plate) == "string", "Expected 'plate' to be a string")
        assert(type(newOwnerIdentifier) == "string", "Expected 'newOwnerIdentifier' to be a string (citizenid)")

        local affectedRows = MySQL.update.await(
            'UPDATE player_vehicles SET citizenid = ?, license = (SELECT license FROM players WHERE citizenid = ?) WHERE plate = ?',
            { newOwnerIdentifier, newOwnerIdentifier, plate }
        )

        return affectedRows and affectedRows > 0
    end,
})
