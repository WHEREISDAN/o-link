if GetResourceState('qb-core') ~= 'started' then return end
if GetResourceState('qbx_core') == 'started' then return end

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
})
