if not olink._guardImpl('Vehicles', 'qb-garages', 'qb-core') then return end
if not olink._hasOverride('Vehicles') and GetResourceState('qbx_core') == 'started' then return end

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
            SELECT pv.plate, pv.vehicle AS model, pv.state, pv.citizenid,
                   p.charinfo
            FROM player_vehicles pv
            LEFT JOIN players p ON pv.citizenid = p.citizenid
            WHERE pv.plate LIKE ?
            ORDER BY pv.plate ASC
            LIMIT ?
        ]], { '%' .. plate .. '%', limit })

        if not rows then return {} end

        local results = {}
        for _, row in ipairs(rows) do
            local charinfo = type(row.charinfo) == 'string' and json.decode(row.charinfo) or row.charinfo or {}
            results[#results + 1] = {
                plate      = row.plate,
                model      = row.model,
                type       = 'car',
                state      = row.state,
                charId     = row.citizenid,
                ownerFirst = charinfo.firstname,
                ownerLast  = charinfo.lastname,
                ownerStateId = row.citizenid,
            }
        end

        return results
    end,

    ---@param charId string citizenid
    ---@return table[]
    GetByOwner = function(charId)
        if not charId then return {} end
        local rows = MySQL.query.await('SELECT plate, vehicle AS model, state FROM player_vehicles WHERE citizenid = ? ORDER BY id DESC', { charId })
        if not rows then return {} end
        for i, row in ipairs(rows) do
            rows[i] = { plate = row.plate, model = row.model, type = 'car', state = row.state }
        end
        return rows
    end,

    ---@param plate string
    ---@return table|nil
    GetByPlate = function(plate)
        if not plate then return nil end

        local row = MySQL.single.await([[
            SELECT pv.*, p.charinfo
            FROM player_vehicles pv
            LEFT JOIN players p ON pv.citizenid = p.citizenid
            WHERE pv.plate = ?
        ]], { plate })

        if not row then return nil end

        local charinfo = type(row.charinfo) == 'string' and json.decode(row.charinfo) or row.charinfo or {}

        return {
            plate      = row.plate,
            model      = row.vehicle,
            type       = 'car',
            state      = row.state,
            charId     = row.citizenid,
            ownerFirst = charinfo.firstname,
            ownerLast  = charinfo.lastname,
            ownerStateId = row.citizenid,
            ownerDob   = charinfo.birthdate,
        }
    end,

    ---@param plate string
    ---@param fee number|nil
    ---@param lot string|nil
    ---@return boolean
    ImpoundVehicle = function(plate, fee, lot)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return false end
        if not MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ? LIMIT 1', { plate }) then return false end

        local sets = { 'state = ?' }
        local params = { 2 }
        if ColumnExists('player_vehicles', 'depotprice') then
            sets[#sets + 1] = 'depotprice = ?'
            params[#params + 1] = tonumber(fee) or 0
        end
        if lot and lot ~= '' and ColumnExists('player_vehicles', 'garage') then
            sets[#sets + 1] = 'garage = ?'
            params[#params + 1] = lot
        end
        params[#params + 1] = plate

        local affected = MySQL.update.await(('UPDATE player_vehicles SET %s WHERE plate = ?'):format(table.concat(sets, ', ')), params)
        return (affected or 0) > 0
    end,

    ---@param plate string
    ---@return boolean
    ReleaseImpound = function(plate)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return false end
        local affected = MySQL.update.await('UPDATE player_vehicles SET state = ? WHERE plate = ?', { 1, plate })
        return (affected or 0) > 0
    end,

    ---@param plate string
    ---@return any
    GetVehicleState = function(plate)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return nil end
        return MySQL.scalar.await('SELECT state FROM player_vehicles WHERE plate = ? LIMIT 1', { plate })
    end,

    ---@param plate string
    ---@param propsJson string
    ---@return boolean
    SaveVehicleProps = function(plate, propsJson)
        plate = NormalizePlate(plate)
        if not plate or plate == '' or not propsJson or not ColumnExists('player_vehicles', 'mods') then return false end
        local affected = MySQL.update.await('UPDATE player_vehicles SET mods = ? WHERE plate = ?', { propsJson, plate })
        return (affected or 0) > 0
    end,
})
