if GetResourceState('oxide-vehicles') == 'missing' then return end

olink._register('vehicleOwnership', {
    ---@return string
    GetResourceName = function()
        return 'oxide-vehicles'
    end,

    ---Transfers vehicle ownership by plate to a new owner (char_id).
    ---@param plate string The vehicle's license plate
    ---@param newOwnerIdentifier number The new owner's character ID
    ---@return boolean success
    TransferOwnership = function(plate, newOwnerIdentifier)
        assert(type(plate) == "string", "Expected 'plate' to be a string")
        assert(newOwnerIdentifier ~= nil, "Expected 'newOwnerIdentifier' to not be nil")

        return exports['oxide-vehicles']:TransferOwnership(plate, tonumber(newOwnerIdentifier))
    end,
})
