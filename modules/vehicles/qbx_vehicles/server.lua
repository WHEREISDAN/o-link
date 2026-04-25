if not olink._guardImpl('Vehicles', 'qbx_vehicles', 'qbx_core') then return end

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

---Resolve a plate to a qbx_vehicles vehicleId using the canonical export when
---available, falling back to a scalar query for older qbx_vehicles versions.
---@param plate string
---@return integer|nil
local function ResolveVehicleIdByPlate(plate)
    local ok, id = pcall(function() return exports.qbx_vehicles:GetVehicleIdByPlate(plate) end)
    if ok and id then return tonumber(id) end
    return tonumber(MySQL.scalar.await('SELECT id FROM player_vehicles WHERE plate = ?', { plate }))
end

---Check if a plate exists in player_vehicles using the canonical export when
---available, falling back to a scalar query.
---@param plate string
---@return boolean
local function PlateExists(plate)
    local ok, exists = pcall(function() return exports.qbx_vehicles:DoesPlayerVehiclePlateExist(plate) end)
    if ok and exists ~= nil then return exists == true end
    return MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ? LIMIT 1', { plate }) ~= nil
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
        if not PlateExists(plate) then return false end

        local sets = { 'state = ?', 'depotprice = ?' }
        local params = { 2, tonumber(fee) or 0 }
        if lot and lot ~= '' then
            sets[#sets + 1] = 'garage = ?'
            params[#params + 1] = lot
        end

        -- Prefer keying on the primary id when we can resolve it (canonical,
        -- avoids any plate-trim mismatch); fall back to plate when not.
        local vehicleId = ResolveVehicleIdByPlate(plate)
        local query, whereValue
        if vehicleId then
            query = ('UPDATE player_vehicles SET %s WHERE id = ?'):format(table.concat(sets, ', '))
            whereValue = vehicleId
        else
            query = ('UPDATE player_vehicles SET %s WHERE plate = ?'):format(table.concat(sets, ', '))
            whereValue = plate
        end
        params[#params + 1] = whereValue

        local affected = MySQL.update.await(query, params)
        if (affected or 0) <= 0 then return false end

        if vehicleId then
            -- Mirror qbx_vehicles' SaveVehicle behavior so any cache listener
            -- (qbx_garages, etc.) invalidates against the new state.
            TriggerEvent('qbx_vehicles:server:vehicleSaved', vehicleId)
        end
        return true
    end,

    ---@param plate string
    ---@return boolean
    ReleaseImpound = function(plate)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return false end

        local vehicleId = ResolveVehicleIdByPlate(plate)
        local query, whereValue
        if vehicleId then
            query = 'UPDATE player_vehicles SET state = ? WHERE id = ?'
            whereValue = vehicleId
        else
            query = 'UPDATE player_vehicles SET state = ? WHERE plate = ?'
            whereValue = plate
        end

        local affected = MySQL.update.await(query, { 1, whereValue })
        if (affected or 0) <= 0 then return false end

        if vehicleId then
            TriggerEvent('qbx_vehicles:server:vehicleSaved', vehicleId)
        end
        return true
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
