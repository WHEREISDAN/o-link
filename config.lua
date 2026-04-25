Config = {}

-- Force a specific implementation for any bridged namespace.
-- Values use implementation folder names and are matched case-insensitively.
-- Leave keys unset or nil to keep normal auto-detection and priority behavior.
-- Notify auto-detection treats ox_lib as a fallback. If multiple non-ox_lib
-- notify resources are running, set Notify explicitly.
Config.Overrides = {
    -- Framework         = 'oxide-core',
    -- Character         = 'oxide-core',
    -- Job               = 'oxide-core',
    -- Money             = 'oxide-accounts',
    -- Inventory         = 'oxide-inventory',
    -- Vehicles          = 'oxide-vehicles',
    -- VehicleProperties = 'vehicleproperties',
    -- VehicleOwnership  = 'oxide-vehicles',
    -- Notify            = 'oxide-notify',
    -- HelpText          = 'ox_lib',
    -- Target            = 'ox_target',
    -- ProgressBar       = 'ox_lib',
    -- VehicleKey        = 'oxide-vehicles',
    -- Fuel              = 'oxide-vehicles',
    -- Weather           = 'oxide-weather',
    -- Input             = 'ox_lib',
    -- Menu              = 'oxide-menu',
    -- Radial            = 'oxide-menu',
    -- Zones             = 'oxlib',
    -- Phone             = 'oxide-phone',
    -- Clothing          = 'oxide-clothing',
    -- Dispatch          = '_default',
    -- Doorlock          = 'ox_doorlock',
    -- Housing           = 'ps-housing',
    -- BossMenu          = 'qbx_management',
    -- Skills            = '_default',
    -- Death             = 'oxide-death',
    -- Needs             = 'oxide-needs',
    -- Gang              = 'oxide-core',
}

Config.Debug = true
