-- Default stub implementations for every client-side o-link namespace.
-- Loaded BEFORE any real implementation so consumers always see callable
-- functions when no provider is installed. Real implementations registered
-- via `olink._register` overwrite these.

local function stub(namespace, methods, defaults)
    olink._registerDefault(namespace, olink._buildStub(namespace, methods, defaults))
end

stub('framework', {
    'GetName', 'GetIsPlayerLoaded',
}, {
    GetName = 'none',
    GetIsPlayerLoaded = false,
})

stub('character', {
    'GetIdentifier', 'GetName', 'GetMetadata',
})

stub('job', {
    'Get', 'GetDuty',
}, {
    GetDuty = false,
})

stub('inventory', {
    'GetPlayerInventory', 'GetItemCount', 'HasItem', 'GetItemInfo',
    'GetImagePath', 'Items',
}, {
    GetPlayerInventory = function() return {} end,
    GetItemCount = 0,
    HasItem = false,
    GetItemInfo = function() return {} end,
    GetImagePath = '',
    Items = function() return {} end,
})

stub('notify', {
    'Send',
})

stub('helptext', {
    'Show', 'Hide',
})

stub('target', {
    'AddBoxZone', 'AddSphereZone', 'RemoveZone', 'AddLocalEntity',
    'RemoveLocalEntity', 'AddModel', 'RemoveModel', 'AddGlobalPed',
    'RemoveGlobalPed', 'AddGlobalVehicle', 'RemoveGlobalVehicle',
    'AddNetworkedEntity', 'RemoveNetworkedEntity',
})

stub('progressbar', {
    'Open',
}, {
    Open = false,
})

stub('vehiclekey', {
    'Give', 'Remove',
})

stub('fuel', {
    'GetFuel', 'GetResourceName', 'SetFuel',
}, {
    GetFuel = 0,
    GetResourceName = 'none',
    SetFuel = false,
})

stub('weather', {
    'GetResourceName', 'GetTime', 'GetWeather', 'ToggleSync',
}, {
    GetResourceName = 'none',
    GetTime = function() return { hour = 12, minute = 0 } end,
    GetWeather = 'CLEAR',
    ToggleSync = false,
})

stub('input', {
    'GetResourceName', 'Open',
}, {
    GetResourceName = 'none',
    Open = function() return nil end,
})

stub('menu', {
    'GetResourceName', 'Open',
}, {
    GetResourceName = 'none',
})

stub('radial', {
    'GetResourceName', 'Register', 'Unregister', 'Open', 'Close',
    'IsOpen', 'GetCurrentId', 'AddItem', 'RemoveItem', 'ClearItems',
    'Disable', 'Refresh', 'RegisterRadial', 'AddRadialItem',
    'RemoveRadialItem', 'ClearRadialItems', 'HideRadial',
    'DisableRadial', 'GetCurrentRadialId',
}, {
    GetResourceName = 'none',
    Register = false,
    Unregister = false,
    Open = false,
    Close = false,
    IsOpen = false,
    AddItem = false,
    RemoveItem = false,
    ClearItems = false,
    Disable = false,
    Refresh = false,
    RegisterRadial = false,
    AddRadialItem = false,
    RemoveRadialItem = false,
    ClearRadialItems = false,
    HideRadial = false,
    DisableRadial = false,
})

stub('zones', {
    'Create', 'Destroy', 'DestroyByResource', 'Get',
}, {
    Destroy = false,
    DestroyByResource = false,
})

stub('phone', {
    'GetPhoneName', 'GetResourceName', 'SendEmail',
}, {
    GetPhoneName = 'none',
    GetResourceName = 'none',
    SendEmail = false,
})

stub('clothing', {
    'GetResourceName', 'OpenMenu',
}, {
    GetResourceName = 'none',
})

stub('dispatch', {
    'GetResourceName', 'SendAlert',
}, {
    GetResourceName = 'none',
    SendAlert = false,
})

stub('doorlock', {
    'GetClosestDoor', 'GetResourceName',
}, {
    GetResourceName = 'none',
})

stub('housing', {
    'GetResourceName',
}, {
    GetResourceName = 'none',
})

stub('bossmenu', {
    'GetResourceName',
}, {
    GetResourceName = 'none',
})

stub('skills', {
    'GetResourceName', 'GetSkillLevel',
}, {
    GetResourceName = 'none',
    GetSkillLevel = 0,
})

stub('death', {
    'GetDeathState', 'IsPlayerDead', 'IsPlayerDowned',
}, {
    IsPlayerDead = false,
    IsPlayerDowned = false,
})

stub('gang', {
    'Get',
})

stub('vehicleproperties', {
    'GetVehicleProperties', 'SetVehicleProperties',
}, {
    SetVehicleProperties = false,
})
