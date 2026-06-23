-- Default stub implementations for every client-side o-link namespace.
-- Loaded BEFORE any real implementation so consumers always see callable
-- functions when no provider is installed. Real implementations registered
-- via `olink._register` overwrite these.

local function stub(namespace, methods, defaults)
    olink._registerDefault(namespace, olink._buildStub(namespace, methods, defaults))
end

stub('framework', {
    'GetName', 'GetIsPlayerLoaded', 'ShowHelpText', 'HideHelpText',
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

stub('multichar', {
    'GetResourceName', 'OnboardNewCharacter', 'SpawnCharacter',
}, {
    GetResourceName = 'none',
    OnboardNewCharacter = function(_, _, onDone) if onDone then onDone(true) end end,
    -- Default: not handled, so the caller falls back to its own teleport.
    SpawnCharacter = false,
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
    'AddNetworkedEntity', 'RemoveNetworkedEntity', 'DisableTargeting',
    'AddGlobalPlayer', 'RemoveGlobalPlayer',
})

stub('progressbar', {
    'Open',
}, {
    Open = false,
})

stub('vehiclekey', {
    'Give', 'Remove', 'GetResourceName', 'GiveKeys', 'RemoveKeys',
}, {
    GetResourceName = 'none',
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
    'GetResourceName', 'Open', 'OpenMenu',
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
    'Create', 'Destroy', 'DestroyByResource', 'Get', 'All',
}, {
    Destroy = false,
    DestroyByResource = false,
    All = function() return {} end,
})

stub('phone', {
    'GetPhoneName', 'GetResourceName', 'SendEmail',
}, {
    GetPhoneName = 'none',
    GetResourceName = 'none',
    SendEmail = false,
})

stub('clothing', {
    'GetResourceName', 'OpenMenu', 'StartCreation', 'ApplyPlayerAppearance',
    'ApplyTattoos', 'GetAppearance', 'SetAppearance', 'RestoreAppearance', 'IsMale',
}, {
    GetResourceName = 'none',
    StartCreation = function(_, onDone) if onDone then onDone(false) end end,
    ApplyPlayerAppearance = false,
    -- Generic, framework-agnostic native impl: every backend's live tattoo
    -- preview uses this identical sequence, so it's a real default, not a stub.
    ApplyTattoos = function(ped, tattoos)
        ped = ped or PlayerPedId()
        if not ped or ped == 0 or not DoesEntityExist(ped) then return false end
        ClearPedDecorations(ped)
        if type(tattoos) == 'table' then
            for _, t in ipairs(tattoos) do
                if t.collection and t.name then
                    AddPedDecorationFromHashes(ped, joaat(t.collection), joaat(t.name))
                end
            end
        end
        return true
    end,
    GetAppearance = function() return {} end,
    SetAppearance = false,
    RestoreAppearance = false,
    IsMale = false,
})

stub('dispatch', {
    'GetResourceName', 'SendAlert',
    'GetActiveAlerts', 'GetAlert', 'RespondToAlert',
    'StopResponding', 'UpdateResponderStatus', 'CloseAlert',
    'SetCallsign', 'SetOfficerStatus', 'TriggerPanic',
}, {
    GetResourceName = 'none',
    SendAlert = false,
    GetActiveAlerts = function() return {} end,
    RespondToAlert = false,
    StopResponding = false,
    UpdateResponderStatus = false,
    CloseAlert = false,
    SetCallsign = false,
    SetOfficerStatus = false,
    TriggerPanic = false,
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

stub('medical', {
    'GetResourceName', 'GetConditions', 'IsInjured',
}, {
    GetResourceName = 'none',
    GetConditions = function() return {} end,
    IsInjured = false,
})

stub('vehicleproperties', {
    'GetVehicleProperties', 'SetVehicleProperties',
}, {
    SetVehicleProperties = false,
})

stub('logger', {
    'GetResourceName',
    'Trace', 'Debug', 'Info', 'Warn', 'Error', 'Fatal',
    'Event', 'CaptureError', 'SafeCall',
}, {
    GetResourceName = 'none',
    Trace = false,
    Debug = false,
    Info  = false,
    Warn  = false,
    Error = false,
    Fatal = false,
    Event = false,
    CaptureError = false,
    SafeCall = function(fn) if type(fn) == 'function' then local ok, r = pcall(fn) return ok and r or nil end end,
})
