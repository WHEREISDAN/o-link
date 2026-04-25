-- Adapter for oxide-vehicles (vehicleOwnership). Registers IMMEDIATELY so
-- consumers that snapshot olink across the resource boundary capture real
-- wrapper refs, not stubs.

local RESOURCE = 'oxide-vehicles'

-- Pure adapter: bail if oxide-vehicles isn't installed so other vehicleOwnership
-- impls (qbx_vehicles, qb-garages, esx_vehicleshop, _default) own the namespace.
if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('VehicleOwnership', RESOURCE, false) then return end

local res = exports[RESOURCE]

local function isStarted()
    return GetResourceState(RESOURCE) == 'started'
end

olink._register('vehicleOwnership', {
    ---@return string
    GetResourceName = function() return RESOURCE end,

    ---Transfers vehicle ownership by plate to a new owner (char_id).
    ---@param plate string The vehicle's license plate
    ---@param newOwnerIdentifier number The new owner's character ID
    ---@return boolean success
    TransferOwnership = function(plate, newOwnerIdentifier)
        if type(plate) ~= 'string' or newOwnerIdentifier == nil then return false end
        if not isStarted() then return false end
        local ok, result = pcall(function()
            return res:TransferOwnership(plate, tonumber(newOwnerIdentifier))
        end)
        return ok and result == true
    end,
}, RESOURCE)
