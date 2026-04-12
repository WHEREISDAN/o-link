if GetResourceState('es_extended') == 'missing' then return end

olink._register('vehicles', {
    ---@param plate string
    ---@param limit number|nil
    ---@return table[]
    SearchByPlate = function(plate, limit)
        limit = limit or 20
        if not plate or #plate < 2 then return {} end

        local rows = MySQL.query.await([[
            SELECT ov.plate, ov.type, ov.stored,
                   u.identifier, u.firstname, u.lastname
            FROM owned_vehicles ov
            LEFT JOIN users u ON ov.owner = u.identifier
            WHERE ov.plate LIKE ?
            ORDER BY ov.plate ASC
            LIMIT ?
        ]], { '%' .. plate .. '%', limit })

        if not rows then return {} end

        local results = {}
        for _, row in ipairs(rows) do
            -- ESX stores vehicle data as JSON in the `vehicle` column, model is inside it
            results[#results + 1] = {
                plate      = row.plate,
                model      = nil, -- would need to decode the vehicle JSON blob
                type       = row.type or 'car',
                state      = row.stored,
                charId     = row.identifier,
                ownerFirst = row.firstname,
                ownerLast  = row.lastname,
                ownerStateId = row.identifier,
            }
        end

        return results
    end,

    ---@param charId string identifier
    ---@return table[]
    GetByOwner = function(charId)
        if not charId then return {} end
        local rows = MySQL.query.await('SELECT plate, type, stored AS state FROM owned_vehicles WHERE owner = ? ORDER BY plate ASC', { charId })
        if not rows then return {} end
        for i, row in ipairs(rows) do
            rows[i] = { plate = row.plate, model = nil, type = row.type or 'car', state = row.state }
        end
        return rows
    end,

    ---@param plate string
    ---@return table|nil
    GetByPlate = function(plate)
        if not plate then return nil end

        local row = MySQL.single.await([[
            SELECT ov.plate, ov.vehicle, ov.type, ov.stored,
                   u.identifier, u.firstname, u.lastname, u.dateofbirth
            FROM owned_vehicles ov
            LEFT JOIN users u ON ov.owner = u.identifier
            WHERE ov.plate = ?
        ]], { plate })

        if not row then return nil end

        -- Try to extract model from the vehicle JSON blob
        local model
        if row.vehicle then
            local vehicleData = type(row.vehicle) == 'string' and json.decode(row.vehicle) or row.vehicle
            if vehicleData then
                model = vehicleData.model
            end
        end

        return {
            plate      = row.plate,
            model      = model,
            type       = row.type or 'car',
            state      = row.stored,
            charId     = row.identifier,
            ownerFirst = row.firstname,
            ownerLast  = row.lastname,
            ownerStateId = row.identifier,
            ownerDob   = row.dateofbirth,
        }
    end,
})
