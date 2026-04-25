-- Adapter for oxide-vehicles. Registers IMMEDIATELY so consumers that snapshot
-- olink across the resource boundary capture real wrapper refs, not stubs.
-- Wrappers gate on the resource being started at call time.

local RESOURCE = 'oxide-vehicles'

-- Pure adapter: bail if the resource isn't installed so other vehicles impls
-- (qbx_vehicles, qb-garages, esx_vehicleshop) own the namespace.
if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Vehicles', RESOURCE, false) then return end

local res = exports[RESOURCE]

local function isStarted()
    return GetResourceState(RESOURCE) == 'started'
end

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
    ---@return string
    GetResourceName = function() return RESOURCE end,

    -- =========================================================
    -- Direct DB queries (used by oxide-police MDT / field tools).
    -- These don't require oxide-vehicles to be started — they
    -- just need the schema, which is shared via oxmysql.
    -- =========================================================

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
                plate        = row.plate,
                model        = row.model,
                type         = row.vehicle_type,
                state        = row.state,
                createdAt    = row.created_at,
                charId       = row.state_id or tostring(row.char_id),
                ownerFirst   = row.first_name,
                ownerLast    = row.last_name,
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
            plate        = row.plate,
            model        = row.model,
            type         = row.vehicle_type,
            state        = row.state,
            createdAt    = row.created_at,
            charId       = row.state_id or tostring(row.char_id),
            ownerFirst   = row.first_name,
            ownerLast    = row.last_name,
            ownerStateId = row.state_id,
            ownerDob     = row.date_of_birth,
        }
    end,

    -- =========================================================
    -- Resource-backed wrappers (call into oxide-vehicles exports)
    -- =========================================================

    ---@return string
    GeneratePlate = function()
        if not isStarted() then return '' end
        local ok, result = pcall(function() return res:GeneratePlate() end)
        return ok and result or ''
    end,

    ---@param charId number
    ---@param model string
    ---@param plate string
    ---@param props table|nil
    ---@param vehicleType string|nil
    ---@return boolean
    RegisterVehicle = function(charId, model, plate, props, vehicleType)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:RegisterVehicle(charId, model, plate, props, vehicleType) end)
        return ok and result == true
    end,

    ---@param plate string
    ---@return boolean
    UnregisterVehicle = function(plate)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return false end
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:UnregisterVehicle(plate) end)
        return ok and result == true
    end,

    ---@param plate string
    ---@return number|nil
    GetVehicleOwner = function(plate)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return nil end
        if not isStarted() then return nil end
        local ok, result = pcall(function() return res:GetVehicleOwner(plate) end)
        return ok and result or nil
    end,

    ---@param charId number
    ---@return table[]
    GetOwnedVehicles = function(charId)
        if not isStarted() then return {} end
        local ok, result = pcall(function() return res:GetOwnedVehicles(charId) end)
        return ok and result or {}
    end,

    ---@param plate string
    ---@return table|nil
    GetVehicleByPlate = function(plate)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return nil end
        if not isStarted() then return nil end
        local ok, result = pcall(function() return res:GetVehicleByPlate(plate) end)
        return ok and result or nil
    end,

    ---@param plate string
    ---@param newCharId number
    ---@return boolean
    TransferOwnership = function(plate, newCharId)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return false end
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:TransferOwnership(plate, tonumber(newCharId)) end)
        return ok and result == true
    end,

    ---@param charId number
    ---@param plate string
    ---@param model string|nil
    ---@return boolean
    GiveKey = function(charId, plate, model)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:GiveKey(charId, plate, model) end)
        return ok and result == true
    end,

    ---@param charId number
    ---@param plate string
    ---@return boolean
    RemoveKey = function(charId, plate)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:RemoveKey(charId, plate) end)
        return ok and result == true
    end,

    ---@param charId number
    ---@param plate string
    ---@return boolean
    HasKey = function(charId, plate)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:HasKey(charId, plate) end)
        return ok and result == true
    end,

    ---@param charId number
    ---@return table[]
    GetKeysForPlayer = function(charId)
        if not isStarted() then return {} end
        local ok, result = pcall(function() return res:GetKeysForPlayer(charId) end)
        return ok and result or {}
    end,

    ---@param plate string
    ---@param fee number|nil
    ---@param lot string|nil
    ---@return boolean
    ImpoundVehicle = function(plate, fee, lot)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return false end
        if not isStarted() then return false end
        local ok = pcall(function()
            res:ImpoundVehicle(plate, tonumber(fee) or 0, lot or 'main')
        end)
        return ok == true
    end,

    ---@param plate string
    ---@return boolean
    ReleaseImpound = function(plate)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return false end
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:ReleaseImpound(plate) end)
        return ok == true and result == true
    end,

    ---@param plate string
    ---@return boolean
    IsVehicleLocked = function(plate)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return false end
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:IsVehicleLocked(plate) end)
        return ok and result == true
    end,

    ---@param plate string
    ---@param locked boolean
    ---@return boolean
    SetVehicleLocked = function(plate, locked)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return false end
        if not isStarted() then return false end
        local ok = pcall(function() res:SetVehicleLocked(plate, locked) end)
        return ok == true
    end,

    ---@param plate string
    ---@return any
    GetVehicleState = function(plate)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return nil end
        if not isStarted() then return nil end
        local ok, result = pcall(function() return res:GetVehicleState(plate) end)
        return ok and result or nil
    end,

    ---@param plate string
    ---@param propsJson string
    ---@return boolean
    SaveVehicleProps = function(plate, propsJson)
        plate = NormalizePlate(plate)
        if not plate or plate == '' or not propsJson then return false end
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:SaveVehicleProps(plate, propsJson) end)
        return ok == true and result == true
    end,

    ---@param plate string
    ---@return boolean
    RepairVehicle = function(plate)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return false end
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:RepairVehicle(plate) end)
        return ok and result == true
    end,

    ---@param groupType string
    ---@param groupName string
    ---@param model string
    ---@param plate string
    ---@param vehicleType string|nil
    ---@param garageName string|nil
    ---@return boolean
    AddSharedVehicle = function(groupType, groupName, model, plate, vehicleType, garageName)
        if not isStarted() then return false end
        local ok, result = pcall(function()
            return res:AddSharedVehicle(groupType, groupName, model, plate, vehicleType, garageName)
        end)
        return ok and result == true
    end,

    ---@param plate string
    ---@return boolean
    RemoveSharedVehicle = function(plate)
        plate = NormalizePlate(plate)
        if not plate or plate == '' then return false end
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:RemoveSharedVehicle(plate) end)
        return ok and result == true
    end,

    ---@param groupType string
    ---@param groupName string
    ---@return table[]
    GetSharedVehicles = function(groupType, groupName)
        if not isStarted() then return {} end
        local ok, result = pcall(function() return res:GetSharedVehicles(groupType, groupName) end)
        return ok and result or {}
    end,
}, RESOURCE)
