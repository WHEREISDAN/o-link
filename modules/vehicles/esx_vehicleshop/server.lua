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

        local hasStored = ColumnExists('owned_vehicles', 'stored')
        local hasPound = ColumnExists('owned_vehicles', 'pound')
        local hasState = ColumnExists('owned_vehicles', 'state')
        local hasParking = ColumnExists('owned_vehicles', 'parking')
        local hasGarage = ColumnExists('owned_vehicles', 'garage')

        local sets = {}
        local params = {}
        if hasPound and hasStored then
            -- Stock esx_garage convention: stored = 2 (in pound), pound = lot, parking = NULL
            sets[#sets + 1] = 'stored = ?'
            params[#params + 1] = 2
            sets[#sets + 1] = 'pound = ?'
            params[#params + 1] = lot or 'main'
            if hasParking then
                sets[#sets + 1] = 'parking = NULL'
            end
        elseif hasState then
            -- Fallback for non-esx_garage installs that have a numeric state column
            sets[#sets + 1] = 'state = ?'
            params[#params + 1] = 2
            if hasStored then
                sets[#sets + 1] = 'stored = ?'
                params[#params + 1] = 0
            end
            if lot and lot ~= '' then
                if hasParking then
                    sets[#sets + 1] = 'parking = ?'
                    params[#params + 1] = lot
                elseif hasGarage then
                    sets[#sets + 1] = 'garage = ?'
                    params[#params + 1] = lot
                end
            end
        elseif hasStored then
            -- Last-resort: stored only (no pound column). Best-effort: stored=2 for impound.
            sets[#sets + 1] = 'stored = ?'
            params[#params + 1] = 2
            if lot and lot ~= '' and hasParking then
                sets[#sets + 1] = 'parking = ?'
                params[#params + 1] = lot
            end
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

        local hasStored = ColumnExists('owned_vehicles', 'stored')
        local hasPound = ColumnExists('owned_vehicles', 'pound')
        local hasState = ColumnExists('owned_vehicles', 'state')

        local sets = {}
        local params = {}
        if hasStored then
            sets[#sets + 1] = 'stored = ?'
            params[#params + 1] = 1  -- back to "stored in garage" — admin no-fee release
        end
        if hasPound then
            sets[#sets + 1] = 'pound = NULL'
        end
        if hasState then
            sets[#sets + 1] = 'state = ?'
            params[#params + 1] = 1
        end
        if ColumnExists('owned_vehicles', 'depotprice') then
            sets[#sets + 1] = 'depotprice = ?'
            params[#params + 1] = 0
        elseif ColumnExists('owned_vehicles', 'impound_fee') then
            sets[#sets + 1] = 'impound_fee = ?'
            params[#params + 1] = 0
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

    ---@param charId string ESX identifier (license-style string)
    ---@param lot string|nil
    ---@return table[]
    GetImpoundedVehicles = function(charId, lot)
        if not charId then return {} end
        local hasPound = ColumnExists('owned_vehicles', 'pound')
        local hasStored = ColumnExists('owned_vehicles', 'stored')
        local hasState = ColumnExists('owned_vehicles', 'state')
        local hasFee = ColumnExists('owned_vehicles', 'depotprice')
            or ColumnExists('owned_vehicles', 'impound_fee')

        local feeCol = ColumnExists('owned_vehicles', 'depotprice') and 'depotprice'
            or ColumnExists('owned_vehicles', 'impound_fee') and 'impound_fee' or nil

        local query, params
        if hasPound and hasStored then
            if lot and lot ~= '' then
                query = ('SELECT plate, vehicle, type, stored, pound%s FROM owned_vehicles WHERE owner = ? AND stored = 2 AND pound = ?')
                    :format(feeCol and (', ' .. feeCol) or '')
                params = { charId, lot }
            else
                query = ('SELECT plate, vehicle, type, stored, pound%s FROM owned_vehicles WHERE owner = ? AND stored = 2')
                    :format(feeCol and (', ' .. feeCol) or '')
                params = { charId }
            end
        elseif hasState then
            query = ('SELECT plate, vehicle, type%s FROM owned_vehicles WHERE owner = ? AND state = 2')
                :format(feeCol and (', ' .. feeCol) or '')
            params = { charId }
        else
            return {}
        end
        local rows = MySQL.query.await(query, params) or {}
        local out = {}
        for i, row in ipairs(rows) do
            local props
            if row.vehicle and row.vehicle ~= '' then
                local okp, decoded = pcall(json.decode, row.vehicle)
                if okp then props = decoded end
            end
            out[i] = {
                id          = row.plate,  -- ESX is plate-keyed; use plate as the ID for retrieval
                plate       = row.plate,
                model       = props and (props.model or props.modelHash) or nil,
                vehicleType = row.type or 'car',
                fee         = feeCol and row[feeCol] or nil,  -- nil signals "police-side handles fee"
                props       = props,
                lot         = row.pound,
            }
        end
        return out
    end,

    ---@param src number
    ---@param vehicleId string|number plate (ESX is plate-keyed)
    ---@param lot string|nil
    ---@return boolean, string|nil
    RetrieveImpounded = function(src, vehicleId, lot)
        if not src or not vehicleId then return false, 'bad_args' end
        local plate = NormalizePlate(tostring(vehicleId))
        if not plate or plate == '' then return false, 'bad_plate' end

        local hasPound = ColumnExists('owned_vehicles', 'pound')
        local hasStored = ColumnExists('owned_vehicles', 'stored')
        local hasParking = ColumnExists('owned_vehicles', 'parking')
        local hasState = ColumnExists('owned_vehicles', 'state')

        local row = MySQL.single.await('SELECT owner, stored, pound, state FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate })
        if not row then return false, 'not_found' end
        local impounded = (hasPound and hasStored and row.stored == 2)
            or (hasState and row.state == 2)
        if not impounded then return false, 'not_impounded' end

        local ESX
        local okEsx = pcall(function() ESX = exports['es_extended']:getSharedObject() end)
        if not okEsx or not ESX then return false, 'no_esx' end
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer or xPlayer.identifier ~= row.owner then return false, 'not_owner' end

        -- ESX has no consistent fee column; police-side deducts via olink.money before
        -- calling this. Atomic state flip — match esx_garage's own retrieval path:
        -- stored = 0 (out, currently driven), pound = NULL, parking = NULL.
        local sets = {}
        local params = {}
        if hasStored then
            sets[#sets + 1] = 'stored = ?'
            params[#params + 1] = 0
        end
        if hasPound then sets[#sets + 1] = 'pound = NULL' end
        if hasParking then sets[#sets + 1] = 'parking = NULL' end
        if hasState then
            sets[#sets + 1] = 'state = ?'
            params[#params + 1] = 0
        end
        if ColumnExists('owned_vehicles', 'depotprice') then
            sets[#sets + 1] = 'depotprice = 0'
        elseif ColumnExists('owned_vehicles', 'impound_fee') then
            sets[#sets + 1] = 'impound_fee = 0'
        end
        if #sets == 0 then return false, 'no_writable_columns' end
        params[#params + 1] = plate

        -- Race-safe: only update if still impounded
        local guard
        if hasPound and hasStored then
            guard = ' AND stored = 2'
        elseif hasState then
            guard = ' AND state = 2'
        else
            guard = ''
        end
        local affected = MySQL.update.await(
            ('UPDATE owned_vehicles SET %s WHERE plate = ?%s'):format(table.concat(sets, ', '), guard),
            params)
        if (affected or 0) <= 0 then return false, 'race_lost' end
        return true, nil
    end,
})
