if not olink._guardImpl('Vehicles', 'esx_vehicleshop', 'es_extended') then return end

local columnCache = {}

local function NormalizePlate(plate)
    return plate and tostring(plate):match('^%s*(.-)%s*$') or nil
end

local function ColumnExists(tableName, columnName)
    local key = tableName .. '.' .. columnName
    if columnCache[key] ~= nil then return columnCache[key] end
    local count = MySQL.scalar.await([[
        SELECT COUNT(*)
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = ?
          AND COLUMN_NAME = ?
    ]], { tableName, columnName })
    columnCache[key] = tonumber(count) ~= nil and tonumber(count) > 0
    return columnCache[key]
end

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

    ---@param plate string
    ---@param fee number|nil
    ---@param lot string|nil
    ---@return boolean
    ImpoundVehicle = function(plate, fee, lot)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return false end
        if not MySQL.scalar.await('SELECT plate FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate }) then return false end

        local sets = {}
        local params = {}
        if ColumnExists('owned_vehicles', 'stored') then
            sets[#sets + 1] = 'stored = ?'
            params[#params + 1] = 0
        end
        if ColumnExists('owned_vehicles', 'state') then
            sets[#sets + 1] = 'state = ?'
            params[#params + 1] = 2
        end
        if lot and lot ~= '' and ColumnExists('owned_vehicles', 'parking') then
            sets[#sets + 1] = 'parking = ?'
            params[#params + 1] = lot
        elseif lot and lot ~= '' and ColumnExists('owned_vehicles', 'garage') then
            sets[#sets + 1] = 'garage = ?'
            params[#params + 1] = lot
        end
        if ColumnExists('owned_vehicles', 'depotprice') then
            sets[#sets + 1] = 'depotprice = ?'
            params[#params + 1] = tonumber(fee) or 0
        elseif ColumnExists('owned_vehicles', 'impound_fee') then
            sets[#sets + 1] = 'impound_fee = ?'
            params[#params + 1] = tonumber(fee) or 0
        end
        if #sets == 0 then return false end
        params[#params + 1] = plate

        local affected = MySQL.update.await(('UPDATE owned_vehicles SET %s WHERE plate = ?'):format(table.concat(sets, ', ')), params)
        return (affected or 0) > 0
    end,

    ---@param plate string
    ---@return boolean
    ReleaseImpound = function(plate)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return false end

        local sets = {}
        local params = {}
        if ColumnExists('owned_vehicles', 'stored') then
            sets[#sets + 1] = 'stored = ?'
            params[#params + 1] = 1
        end
        if ColumnExists('owned_vehicles', 'state') then
            sets[#sets + 1] = 'state = ?'
            params[#params + 1] = 1
        end
        if #sets == 0 then return false end
        params[#params + 1] = plate

        local affected = MySQL.update.await(('UPDATE owned_vehicles SET %s WHERE plate = ?'):format(table.concat(sets, ', ')), params)
        return (affected or 0) > 0
    end,

    ---@param plate string
    ---@return any
    GetVehicleState = function(plate)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return nil end
        if ColumnExists('owned_vehicles', 'state') then
            return MySQL.scalar.await('SELECT state FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate })
        end
        if ColumnExists('owned_vehicles', 'stored') then
            return MySQL.scalar.await('SELECT stored FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate })
        end
        return nil
    end,

    ---@param plate string
    ---@param propsJson string
    ---@return boolean
    SaveVehicleProps = function(plate, propsJson)
        plate = NormalizePlate(plate)
        if not plate or plate == '' or not propsJson or not ColumnExists('owned_vehicles', 'vehicle') then return false end
        local affected = MySQL.update.await('UPDATE owned_vehicles SET vehicle = ? WHERE plate = ?', { propsJson, plate })
        return (affected or 0) > 0
    end,
})
