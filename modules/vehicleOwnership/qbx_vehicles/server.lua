if GetResourceState('qbx_vehicles') == 'missing' then return end

olink._register('vehicleOwnership', {
    ---@return string
    GetResourceName = function()
        return 'qbx_vehicles'
    end,

    ---Transfers vehicle ownership by plate to a new owner (citizenid).
    ---Uses qbx_vehicles exports: GetVehicleIdByPlate + SetPlayerVehicleOwner.
    ---@param plate string The vehicle's license plate
    ---@param newOwnerIdentifier string The new owner's citizenid
    ---@return boolean success
    TransferOwnership = function(plate, newOwnerIdentifier)
        assert(type(plate) == "string", "Expected 'plate' to be a string")
        assert(type(newOwnerIdentifier) == "string", "Expected 'newOwnerIdentifier' to be a string (citizenid)")

        local vehicleId = exports.qbx_vehicles:GetVehicleIdByPlate(plate)
        if not vehicleId then
            return false
        end

        local success = exports.qbx_vehicles:SetPlayerVehicleOwner(vehicleId, newOwnerIdentifier)
        return success == true
    end,
})
