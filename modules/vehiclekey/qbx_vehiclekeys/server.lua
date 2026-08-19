if not olink._guardImpl('VehicleKey', 'qbx_vehiclekeys', 'qbx_vehiclekeys') then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('oxide-vehicles') == 'started' then return end

---@param src number
---@param vehicle number Entity handle
---@return boolean
local function giveKeys(src, vehicle)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    return exports.qbx_vehiclekeys:GiveKeys(src, vehicle) == true
end

olink._register('vehiclekey', {
    ---@return string
    GetResourceName = function()
        return 'qbx_vehiclekeys'
    end,

    ---@param src number
    ---@param vehicle number Entity handle
    ---@return boolean
    Give = giveKeys,

    ---@param src number
    ---@param vehicle number Entity handle
    ---@return boolean
    Remove = function(src, vehicle)
        if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return false end
        return exports.qbx_vehiclekeys:RemoveKeys(src, vehicle) == true
    end,
})

-- qbx_vehiclekeys 1.0.3+ denies client-triggered grants for vehicles beyond
-- config.distanceToVehicle, so keys for freshly spawned job vehicles must be
-- granted server-side. Restricted to vehicles the requester network-owns
-- (true for vehicles the client just spawned) so this does not reopen the
-- arbitrary-plate exploit that proximity check closed.
RegisterNetEvent('o-link:server:vehiclekey:give', function(netId)
    local src = source
    if type(netId) ~= 'number' or netId == 0 then return end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end
    if GetEntityType(vehicle) ~= 2 then return end
    if NetworkGetEntityOwner(vehicle) ~= src then return end

    giveKeys(src, vehicle)
end)
