-- Default vehicle key fallback.

if not olink._guardImpl('VehicleKey', '_default', false) then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('cd_garage') == 'started' then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('f_realcarkeyssystem') == 'started' then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('jacksam') == 'started' then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('mVehicle') == 'started' then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('mk_vehiclekeys') == 'started' then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('MrNewbVehicleKeys') == 'started' then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('mrnewbvehiclekeys') == 'started' then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('okokGarage') == 'started' then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('oxide-vehicles') == 'started' then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('qb-vehiclekeys') == 'started' then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('qbx_vehiclekeys') == 'started' then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('qs-vehiclekeys') == 'started' then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('Renewed-Vehiclekeys') == 'started' then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('renewed-vehiclekeys') == 'started' then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('t1ger_keys') == 'started' then return end
if not olink._hasOverride('VehicleKey') and GetResourceState('wasabi_carlock') == 'started' then return end

olink._registerDefault('vehiclekey', olink._buildStub('vehiclekey', {
    'Give',
    'Remove',
    'GiveKeys',
    'RemoveKeys',
}))

olink._registerDefault('vehiclekey', {
    GetResourceName = function() return '_default' end,
})
