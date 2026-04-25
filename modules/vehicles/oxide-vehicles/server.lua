if not olink._guardImpl('Vehicles', 'oxide-vehicles', 'oxide-vehicles') then return end

---Resolve a stateId to numeric char_id for DB queries
---@param identifier string stateId or char_id
---@return number|nil
local function ResolveCharId(identifier)
    local num = tonumber(identifier)
    if num then return num end
    local row = MySQL.scalar.await('SELECT char_id FROM characters WHERE state_id = ? AND deleted_at IS NULL', { identifier })
    return tonumber(row)
end

local function NormalizePlate(plate)
    return plate and tostring(plate):match('^%s*(.-)%s*$') or nil
end

olink._register('vehicles', {
    ---@param plate string
    ---@param limit number|nil
    ---@return table[]
    SearchByPlate = function(plate, limit)
        limit = limit or 20
        if not plate or #plate < 2 then return {} end

        local rows = MySQL.query.await([[
            SELECT ov.plate, ov.model, ov.vehicle_type, ov.state, ov.created_at,
                   c.char_id, c.first_name, c.last_name, c.state_id
            FROM owned_vehicles ov
            LEFT JOIN characters c ON ov.char_id = c.char_id
            WHERE ov.plate LIKE ?
            ORDER BY ov.plate ASC
            LIMIT ?
        ]], { '%' .. plate .. '%', limit })

        if not rows then return {} end

        for i, row in ipairs(rows) do
            rows[i] = {
                plate      = row.plate,
                model      = row.model,
                type       = row.vehicle_type,
                state      = row.state,
                createdAt  = row.created_at,
                charId     = row.state_id or tostring(row.char_id),
                ownerFirst = row.first_name,
                ownerLast  = row.last_name,
                ownerStateId = row.state_id,
            }
        end

        return rows
    end,

    ---@param identifier string stateId or char_id
    ---@return table[]
    GetByOwner = function(identifier)
        if not identifier then return {} end
        local charId = ResolveCharId(identifier)
        if not charId then return {} end
        local rows = MySQL.query.await([[
            SELECT plate, model, vehicle_type, state, created_at
            FROM owned_vehicles WHERE char_id = ? ORDER BY created_at DESC
        ]], { charId })
        if not rows then return {} end
        for i, row in ipairs(rows) do
            rows[i] = { plate = row.plate, model = row.model, type = row.vehicle_type, state = row.state, createdAt = row.created_at }
        end
        return rows
    end,

    ---@param plate string
    ---@return table|nil
    GetByPlate = function(plate)
        if not plate then return nil end

        local row = MySQL.single.await([[
            SELECT ov.*, c.char_id, c.first_name, c.last_name, c.state_id, c.date_of_birth
            FROM owned_vehicles ov
            LEFT JOIN characters c ON ov.char_id = c.char_id
            WHERE ov.plate = ?
        ]], { plate })

        if not row then return nil end

        return {
            plate      = row.plate,
            model      = row.model,
            type       = row.vehicle_type,
            state      = row.state,
            createdAt  = row.created_at,
            charId     = row.state_id or tostring(row.char_id),
            ownerFirst = row.first_name,
            ownerLast  = row.last_name,
            ownerStateId = row.state_id,
            ownerDob   = row.date_of_birth,
        }
    end,

    ---@param plate string
    ---@param fee number|nil
    ---@param lot string|nil
    ---@return boolean
    ImpoundVehicle = function(plate, fee, lot)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return false end
        if GetResourceState('oxide-vehicles') ~= 'started' then return false end
        local ok = pcall(function()
            exports['oxide-vehicles']:ImpoundVehicle(plate, tonumber(fee) or 0, lot or 'main')
        end)
        return ok == true
    end,

    ---@param plate string
    ---@return boolean
    ReleaseImpound = function(plate)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return false end
        if GetResourceState('oxide-vehicles') ~= 'started' then return false end
        local ok, result = pcall(function()
            return exports['oxide-vehicles']:ReleaseImpound(plate)
        end)
        return ok == true and result == true
    end,

    ---@param plate string
    ---@return any
    GetVehicleState = function(plate)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return nil end
        if GetResourceState('oxide-vehicles') ~= 'started' then return nil end
        local ok, result = pcall(function()
            return exports['oxide-vehicles']:GetVehicleState(plate)
        end)
        return ok and result or nil
    end,

    ---@param plate string
    ---@param propsJson string
    ---@return boolean
    SaveVehicleProps = function(plate, propsJson)
        plate = NormalizePlate(plate)
        if not plate or plate == '' or not propsJson then return false end
        if GetResourceState('oxide-vehicles') ~= 'started' then return false end
        local ok, result = pcall(function()
            return exports['oxide-vehicles']:SaveVehicleProps(plate, propsJson)
        end)
        return ok == true and result == true
    end,
})
