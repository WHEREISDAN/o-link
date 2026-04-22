-- Default vehicleOwnership fallback.

if not olink._guardImpl('VehicleOwnership', '_default', false) then return end
if not olink._hasOverride('VehicleOwnership') and GetResourceState('esx_vehicleshop') == 'started' then return end
if not olink._hasOverride('VehicleOwnership') and GetResourceState('oxide-vehicles') == 'started' then return end
if not olink._hasOverride('VehicleOwnership') and GetResourceState('qb-garages') == 'started' then return end
if not olink._hasOverride('VehicleOwnership') and GetResourceState('qbx_vehicles') == 'started' then return end

olink._registerDefault('vehicleOwnership', olink._buildStub('vehicleOwnership', {
    'TransferOwnership',
}, {
    TransferOwnership = false,
}))

olink._registerDefault('vehicleOwnership', {
    GetResourceName = function() return '_default' end,
})
