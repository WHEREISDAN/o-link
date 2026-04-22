-- Default clothing fallback.
-- Provides a minimal appearance API using client callbacks/events when no
-- dedicated clothing resource is running.

if not olink._guardImpl('Clothing', '_default', false) then return end
if not olink._hasOverride('Clothing') and GetResourceState('esx_skin') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('fivem-appearance') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('illenium-appearance') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('oxide-clothing') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('oxide-identity') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('qb-clothing') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('rcore_clothing') == 'started' then return end

local LastAppearance = {}

local function IsMale(src)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end
    return GetEntityModel(ped) == `mp_m_freemode_01`
end

local function GetAppearance(src)
    if not olink.callback then return {} end
    return olink.callback.Trigger('o-link:clothing:getAppearance', src)
end

local function SetAppearance(src, data)
    LastAppearance[tostring(src)] = GetAppearance(src)
    TriggerClientEvent('o-link:clothing:setAppearance', src, data)
end

olink._registerDefault('clothing', {
    GetResourceName = function() return '_default' end,

    IsMale = IsMale,
    GetAppearance = GetAppearance,
    SetAppearance = SetAppearance,

    SetAppearanceExt = function(src, data)
        local tbl = IsMale(src) and data.male or data.female
        SetAppearance(src, tbl)
    end,

    RestoreAppearance = function(src)
        TriggerClientEvent('o-link:clothing:restoreAppearance', src)
    end,

    SaveOutfit = function() return nil end,
    GetOutfits = function() return {} end,
    UpdateOutfit = function() return false end,
    DeleteOutfit = function() return false end,
})
