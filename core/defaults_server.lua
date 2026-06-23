-- Default stub implementations for every server-side o-link namespace.
-- These are loaded BEFORE any real implementation so that, when no
-- framework/resource provides a given namespace, consuming resources still see
-- callable functions (that warn and return nil/false) instead of indexing into
-- a missing namespace and crashing.
--
-- Real implementations registered via `olink._register` overwrite these stubs.

local function stub(namespace, methods, defaults)
    olink._registerDefault(namespace, olink._buildStub(namespace, methods, defaults))
end

stub('framework', {
    'GetName', 'GetIsPlayerLoaded', 'GetPlayers', 'GetJobs', 'IsAdmin',
    'RegisterUsableItem', 'Logout', 'GetPlayerInventory', 'ItemList', 'GetStatus',
}, {
    GetName = 'none',
    GetIsPlayerLoaded = false,
    GetPlayers = function() return {} end,
    GetJobs = function() return {} end,
    IsAdmin = false,
    Logout = false,
    GetPlayerInventory = function() return {} end,
    ItemList = function() return {} end,
})

stub('character', {
    'GetIdentifier', 'GetName', 'GetMetadata', 'SetMetadata', 'GetAllMetadata',
    'SetBoss', 'IsBoss', 'Search', 'GetOffline', 'GetDob', 'GetAccountCharacterIdentifiers',
}, {
    Search = function() return {} end,
    IsBoss = false,
    SetBoss = false,
    SetMetadata = false,
    GetAccountCharacterIdentifiers = function() return {} end,
})

stub('multichar', {
    'GetResourceName', 'List', 'Create', 'Select', 'Delete', 'GetSlotInfo', 'Logout',
}, {
    GetResourceName = 'none',
    List = function() return {} end,
    Create = function() return { ok = false, error = 'No multichar provider' } end,
    Select = function() return { ok = false, error = 'No multichar provider' } end,
    Delete = false,
    GetSlotInfo = function() return { used = 0 } end,
    Logout = false,
})

stub('job', {
    'Get', 'Set', 'SetDuty', 'GetDuty', 'GetPlayersWithJob', 'DoesPlayerHaveJob',
}, {
    Set = false,
    SetDuty = false,
    GetDuty = false,
    GetPlayersWithJob = function() return {} end,
    DoesPlayerHaveJob = false,
})

stub('money', {
    'Add', 'Remove', 'GetBalance', 'AddOffline', 'RemoveOffline', 'GetBalanceOffline',
}, {
    Add = false,
    Remove = false,
    GetBalance = 0,
    AddOffline = false,
    RemoveOffline = false,
    GetBalanceOffline = 0,
})

stub('license', {
    'Has', 'Grant', 'Revoke', 'GetAll',
    'HasOffline', 'GrantOffline', 'RevokeOffline', 'GetAllOffline',
}, {
    Has = false,
    Grant = false,
    Revoke = false,
    GetAll = function() return {} end,
    HasOffline = false,
    GrantOffline = false,
    RevokeOffline = false,
    GetAllOffline = function() return {} end,
})

stub('inventory', {
    'GetItemCount', 'HasItem', 'AddItem', 'RemoveItem', 'GetItemBySlot',
    'GetPlayerInventory', 'OpenPlayerInventory', 'RegisterStash', 'OpenStash',
    'GetItemInfo', 'GetImagePath', 'CanCarryItem', 'ClearStash', 'GetStashItems',
    'Items', 'OpenShop', 'RegisterShop', 'RemoveStashItem', 'AddStashItem',
    'SetMetadata', 'UpdatePlate', 'AddTrunkItems', 'AddStashItems',
}, {
    AddStashItems = false,
    GetItemCount = 0,
    HasItem = false,
    AddItem = false,
    RemoveItem = false,
    GetPlayerInventory = function() return {} end,
    OpenPlayerInventory = false,
    RegisterStash = false,
    GetItemInfo = function() return {} end,
    GetImagePath = '',
    CanCarryItem = false,
    ClearStash = false,
    GetStashItems = function() return {} end,
    Items = function() return {} end,
    RegisterShop = false,
    RemoveStashItem = false,
    AddStashItem = false,
    SetMetadata = false,
    UpdatePlate = false,
    AddTrunkItems = false,
})

stub('vehicles', {
    'SearchByPlate', 'GetByPlate', 'GetByOwner', 'ImpoundVehicle',
    'ReleaseImpound', 'GetImpoundedVehicles', 'RetrieveImpounded',
    'GetVehicleState', 'SaveVehicleProps',
    'GeneratePlate', 'RegisterVehicle', 'UnregisterVehicle', 'GetVehicleOwner',
    'GetOwnedVehicles', 'GetVehicleByPlate', 'GiveKey', 'RemoveKey', 'HasKey',
    'GetKeysForPlayer', 'IsVehicleLocked', 'SetVehicleLocked', 'RepairVehicle',
    'AddSharedVehicle', 'RemoveSharedVehicle', 'GetSharedVehicles',
    'IsOwnedBy', 'GetOwnedPlates', 'TransferOwnership',
}, {
    IsOwnedBy = false,
    GetOwnedPlates = function() return {} end,
    TransferOwnership = false,
    SearchByPlate = function() return {} end,
    GetByOwner = function() return {} end,
    ImpoundVehicle = false,
    ReleaseImpound = false,
    GetImpoundedVehicles = function() return {} end,
    RetrieveImpounded = function() return false, 'unsupported' end,
    GetVehicleState = false,
    SaveVehicleProps = false,
    GeneratePlate = function() return '' end,
    RegisterVehicle = false,
    UnregisterVehicle = false,
    GetOwnedVehicles = function() return {} end,
    GiveKey = false,
    RemoveKey = false,
    HasKey = false,
    GetKeysForPlayer = function() return {} end,
    IsVehicleLocked = false,
    SetVehicleLocked = false,
    RepairVehicle = false,
    AddSharedVehicle = false,
    RemoveSharedVehicle = false,
    GetSharedVehicles = function() return {} end,
})

stub('vehicleOwnership', {
    'GetResourceName', 'TransferOwnership',
}, {
    GetResourceName = 'none',
    TransferOwnership = false,
})

stub('banking', {
    'AddAccountMoney', 'GetAccountMoney', 'GetManagmentName', 'GetResourceName',
    'RemoveAccountMoney',
    'IsReady', 'GetAccount',
    'CreatePlayerAccount', 'CreateJobAccount', 'GetPlayerAccounts',
    'GetPlayerBankingData', 'GetCreditScore', 'CanAfford',
    'CreateInvoice', 'GetInvoices',
}, {
    AddAccountMoney = false,
    GetAccountMoney = 0,
    GetManagmentName = 'none',
    GetResourceName = 'none',
    RemoveAccountMoney = false,
    IsReady = false,
    CreatePlayerAccount = false,
    CreateJobAccount = false,
    GetPlayerAccounts = function() return {} end,
    GetCreditScore = function() return 600 end,
    CanAfford = false,
    CreateInvoice = false,
    GetInvoices = function() return {} end,
})

stub('notify', {
    'Send', 'Confirm', 'SendNotification', 'SendNotify',
})

stub('phone', {
    'GetPhoneName', 'GetResourceName', 'GetPlayerPhone', 'SendEmail',
}, {
    GetPhoneName = 'none',
    GetResourceName = 'none',
    GetPlayerPhone = false,
    SendEmail = false,
})

stub('clothing', {
    'DeleteOutfit', 'GetAppearance', 'GetCanonicalAppearance', 'GetOfflineAppearance', 'GetOutfits',
    'GetResourceName', 'GetTattoos', 'IsMale', 'OpenMenu', 'Revert', 'SaveCreatorAppearance',
    'SaveOutfit', 'SaveTattoos', 'SetAppearance', 'SetAppearanceExt', 'UpdateOutfit', 'Save',
}, {
    Save = false,
    DeleteOutfit = false,
    GetAppearance = function() return {} end,
    GetCanonicalAppearance = function() return nil end,
    GetOfflineAppearance = function() return nil end,
    GetOutfits = function() return {} end,
    GetResourceName = 'none',
    GetTattoos = function() return {} end,
    IsMale = true,
    -- Returns false when no backend implements it (e.g. esx_skin) so
    -- oxide-multichar falls back to the framework's native first-char editor.
    SaveCreatorAppearance = false,
    SaveOutfit = false,
    SaveTattoos = false,
    SetAppearance = false,
    SetAppearanceExt = false,
    UpdateOutfit = false,
})

stub('dispatch', {
    'GetResourceName',
    'CreateAlert', 'GetActiveAlerts', 'GetAlert', 'RespondToAlert',
    'StopResponding', 'UpdateResponderStatus', 'CloseAlert',
    'SetCallsign', 'SetOfficerStatus', 'GetOfficerStatus', 'TriggerPanic',
}, {
    GetResourceName = 'none',
    GetActiveAlerts = function() return {} end,
    RespondToAlert = false,
    StopResponding = false,
    UpdateResponderStatus = false,
    CloseAlert = false,
    SetCallsign = false,
    SetOfficerStatus = false,
    GetOfficerStatus = function() return nil end,
    TriggerPanic = false,
})

stub('doorlock', {
    'GetResourceName', 'ToggleDoorLock',
}, {
    GetResourceName = 'none',
    ToggleDoorLock = false,
})

-- GetOwnedProperties entries: { id, kind, label, coords? } where coords is the
-- property's exterior { x, y, z } when the backend can resolve it (optional).
stub('housing', {
    'GetResourceName', 'GetOwnedProperties', 'CreateStartingApartment', 'SpawnInside',
    'ListStarterApartments',
}, {
    GetResourceName = 'none',
    GetOwnedProperties = function() return {} end,
    CreateStartingApartment = false,
    SpawnInside = false,
    ListStarterApartments = function() return {} end,
})

stub('bossmenu', {
    'GetResourceName', 'OpenBossMenu',
}, {
    GetResourceName = 'none',
    OpenBossMenu = false,
})

stub('skills', {
    'AddXp', 'Create', 'GetResourceName', 'GetScaledXP', 'GetSkillLevel',
    'GetXP', 'GetXPRequiredForLevel', 'RemoveXp', 'SetSkillLevel', 'SetXP',
}, {
    AddXp = false,
    Create = false,
    GetResourceName = 'none',
    GetScaledXP = 0,
    GetSkillLevel = 0,
    GetXP = 0,
    GetXPRequiredForLevel = 0,
    RemoveXp = false,
    SetSkillLevel = false,
    SetXP = false,
})

stub('death', {
    'DownPlayer', 'GetDeathState', 'IsPlayerDead', 'IsPlayerDowned',
    'KillPlayer', 'RespawnPlayer', 'RevivePlayer',
}, {
    DownPlayer = false,
    IsPlayerDead = false,
    IsPlayerDowned = false,
    KillPlayer = false,
    RespawnPlayer = false,
    RevivePlayer = false,
})

stub('needs', {
    'GetNeed', 'ModifyNeed', 'SetNeed',
}, {
    GetNeed = 0,
    ModifyNeed = false,
    SetNeed = false,
})

stub('medical', {
    'GetResourceName',
    'GetRecord', 'GetBloodType', 'GetDNA', 'GetImmunity', 'GetConditions', 'HasCondition',
    'AddCondition', 'TreatCondition', 'RemoveCondition', 'GetOfflineRecord',
}, {
    GetResourceName = 'none',
    GetImmunity = 100,
    GetConditions = function() return {} end,
    HasCondition = false,
    AddCondition = false,
    TreatCondition = false,
    RemoveCondition = false,
})

stub('gang', {
    'Get', 'Set', 'DoesPlayerHaveGang',
}, {
    Set = false,
    DoesPlayerHaveGang = false,
})

stub('helptext', {
    'Show', 'Hide',
})

stub('logger', {
    'GetResourceName',
    'Trace', 'Debug', 'Info', 'Warn', 'Error', 'Fatal',
    'Event', 'CaptureError', 'SafeCall',
    'SetLevel', 'GetLevel',
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
    SetLevel = false,
    GetLevel = 'info',
})
