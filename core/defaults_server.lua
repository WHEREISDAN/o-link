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
    'RegisterUsableItem', 'Logout',
}, {
    GetName = 'none',
    GetIsPlayerLoaded = false,
    GetPlayers = function() return {} end,
    GetJobs = function() return {} end,
    IsAdmin = false,
    Logout = false,
})

stub('character', {
    'GetIdentifier', 'GetName', 'GetMetadata', 'SetMetadata', 'GetAllMetadata',
    'SetBoss', 'IsBoss', 'Search', 'GetOffline',
}, {
    Search = function() return {} end,
    IsBoss = false,
    SetBoss = false,
    SetMetadata = false,
})

stub('job', {
    'Get', 'Set', 'SetDuty', 'GetDuty', 'GetPlayersWithJob',
}, {
    Set = false,
    SetDuty = false,
    GetDuty = false,
    GetPlayersWithJob = function() return {} end,
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

stub('inventory', {
    'GetItemCount', 'HasItem', 'AddItem', 'RemoveItem', 'GetItemBySlot',
    'GetPlayerInventory', 'OpenPlayerInventory', 'RegisterStash', 'OpenStash',
    'GetItemInfo', 'GetImagePath', 'CanCarryItem', 'ClearStash', 'GetStashItems',
    'Items', 'OpenShop', 'RegisterShop', 'RemoveStashItem', 'AddStashItem',
    'SetMetadata', 'UpdatePlate', 'AddTrunkItems',
}, {
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
    'ReleaseImpound', 'GetVehicleState', 'SaveVehicleProps',
    'GeneratePlate', 'RegisterVehicle', 'UnregisterVehicle', 'GetVehicleOwner',
    'GetOwnedVehicles', 'GetVehicleByPlate', 'GiveKey', 'RemoveKey', 'HasKey',
    'GetKeysForPlayer', 'IsVehicleLocked', 'SetVehicleLocked', 'RepairVehicle',
    'AddSharedVehicle', 'RemoveSharedVehicle', 'GetSharedVehicles',
}, {
    SearchByPlate = function() return {} end,
    GetByOwner = function() return {} end,
    ImpoundVehicle = false,
    ReleaseImpound = false,
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
    'IsReady', 'GetBalance', 'GetAccount', 'AddMoney', 'RemoveMoney',
    'CreatePlayerAccount', 'CreateJobAccount', 'GetPlayerAccounts',
    'GetPlayerBankingData', 'GetCreditScore', 'CanAfford',
}, {
    AddAccountMoney = false,
    GetAccountMoney = 0,
    GetManagmentName = 'none',
    GetResourceName = 'none',
    RemoveAccountMoney = false,
    IsReady = false,
    GetBalance = 0,
    AddMoney = false,
    RemoveMoney = false,
    CreatePlayerAccount = false,
    CreateJobAccount = false,
    GetPlayerAccounts = function() return {} end,
    GetCreditScore = function() return 600 end,
    CanAfford = false,
})

stub('notify', {
    'Send', 'Confirm',
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
    'DeleteOutfit', 'GetAppearance', 'GetOutfits', 'GetResourceName', 'IsMale',
    'OpenMenu', 'Revert', 'SaveOutfit', 'SetAppearance', 'SetAppearanceExt',
    'UpdateOutfit',
}, {
    DeleteOutfit = false,
    GetAppearance = function() return {} end,
    GetOutfits = function() return {} end,
    GetResourceName = 'none',
    IsMale = true,
    SaveOutfit = false,
    SetAppearance = false,
    SetAppearanceExt = false,
    UpdateOutfit = false,
})

stub('dispatch', {
    'GetResourceName',
    'CreateAlert', 'GetActiveAlerts', 'GetAlert', 'RespondToAlert',
    'StopResponding', 'UpdateResponderStatus', 'CloseAlert',
}, {
    GetResourceName = 'none',
    GetActiveAlerts = function() return {} end,
    RespondToAlert = false,
    StopResponding = false,
    UpdateResponderStatus = false,
    CloseAlert = false,
})

stub('doorlock', {
    'GetResourceName', 'ToggleDoorLock',
}, {
    GetResourceName = 'none',
    ToggleDoorLock = false,
})

stub('housing', {
    'GetResourceName',
}, {
    GetResourceName = 'none',
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

stub('gang', {
    'Get', 'Set',
}, {
    Set = false,
})

stub('helptext', {
    'Show', 'Hide',
})
