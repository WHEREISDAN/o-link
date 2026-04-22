-- Framework-agnostic vehicle ownership helpers.

olink._register('vehicles', {
    ---Check whether the vehicle with the given plate is owned by the player.
    ---@param src number
    ---@param plate string
    ---@return boolean
    IsOwnedBy = function(src, plate)
        if not plate or type(plate) ~= 'string' then return false end
        if not olink.vehicles or not olink.vehicles.GetByPlate then return false end
        if not olink.character or not olink.character.GetIdentifier then return false end

        local vehicle = olink.vehicles.GetByPlate(plate)
        if not vehicle then return false end

        local charId = olink.character.GetIdentifier(src)
        if not charId then return false end

        return (vehicle.owner == charId) or (vehicle.citizenid == charId) or (vehicle.identifier == charId)
    end,

    ---Convenience wrapper: list plates owned by the given player.
    ---@param src number
    ---@return string[]
    GetOwnedPlates = function(src)
        if not olink.vehicles or not olink.vehicles.GetByOwner then return {} end
        if not olink.character or not olink.character.GetIdentifier then return {} end

        local charId = olink.character.GetIdentifier(src)
        if not charId then return {} end

        local vehicles = olink.vehicles.GetByOwner(charId) or {}
        local plates = {}
        for _, v in ipairs(vehicles) do
            if v.plate then plates[#plates + 1] = v.plate end
        end
        return plates
    end,
})
