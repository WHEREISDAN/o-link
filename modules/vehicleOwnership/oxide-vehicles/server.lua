local RESOURCE = 'oxide-vehicles'

if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('VehicleOwnership', RESOURCE, false) then return end

local res = exports[RESOURCE]

local function isStarted()
    return GetResourceState(RESOURCE) == 'started'
end

---Resolve a stateId (alphanumeric) or numeric char_id to the numeric char_id that
---owned_vehicles.char_id expects. olink.character identifiers are state_ids, so a
---blind tonumber() turns them into nil and the transfer silently no-ops.
---@param identifier string|number stateId or char_id
---@return number|nil
local function ResolveCharId(identifier)
    local num = tonumber(identifier)
    if num then return num end
    local row = MySQL.scalar.await('SELECT char_id FROM characters WHERE state_id = ? AND deleted_at IS NULL', { identifier })
    return tonumber(row)
end

olink._register('vehicleOwnership', {
    ---@return string
    GetResourceName = function() return RESOURCE end,

    ---Transfers vehicle ownership by plate to a new owner (stateId or char_id).
    ---@param plate string The vehicle's license plate
    ---@param newOwnerIdentifier string|number The new owner's stateId or char_id
    ---@return boolean success
    TransferOwnership = function(plate, newOwnerIdentifier)
        if type(plate) ~= 'string' or newOwnerIdentifier == nil then return false end
        if not isStarted() then return false end
        local cid = ResolveCharId(newOwnerIdentifier)
        if not cid then return false end
        local ok, result = pcall(function()
            return res:TransferOwnership(plate, cid)
        end)
        return ok and result == true
    end,
}, RESOURCE)
