-- Default target fallback.
-- Loads when no dedicated target resource is running; most methods are stubs.

if not olink._guardImpl('Target', '_default', false) then return end
if not olink._hasOverride('Target') and GetResourceState('ox_target') == 'started' then return end
if not olink._hasOverride('Target') and GetResourceState('qb-target') == 'started' then return end
if not olink._hasOverride('Target') and GetResourceState('sleepless_interact') == 'started' then return end

olink._registerDefault('target', olink._buildStub('target', {
    'AddBoxZone',
    'AddSphereZone',
    'AddPolyZone',
    'AddLocalEntity',
    'AddModel',
    'AddGlobalPed',
    'AddGlobalPlayer',
    'AddGlobalVehicle',
    'AddNetworkedEntity',
    'RemoveZone',
    'RemoveLocalEntity',
    'RemoveModel',
    'RemoveGlobalPed',
    'RemoveGlobalPlayer',
    'RemoveGlobalVehicle',
    'RemoveNetworkedEntity',
    'DisableTargeting',
}))

olink._registerDefault('target', {
    GetResourceName = function() return '_default' end,
})
