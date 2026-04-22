-- Default clothing fallback (client).
-- Uses GTA native ped-component APIs when no dedicated clothing resource is running.

if not olink._guardImpl('Clothing', '_default', false) then return end
if not olink._hasOverride('Clothing') and GetResourceState('esx_skin') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('fivem-appearance') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('illenium-appearance') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('oxide-clothing') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('oxide-identity') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('qb-clothing') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('rcore_clothing') == 'started' then return end

local appearanceBackup

local function GetAppearance(entity)
    entity = entity or PlayerPedId()
    if not DoesEntityExist(entity) then return {} end
    local skinData = { model = GetEntityModel(entity), components = {}, props = {} }
    for i = 0, 11 do
        skinData.components[#skinData.components + 1] = {
            component_id = i,
            drawable = GetPedDrawableVariation(entity, i),
            texture = GetPedTextureVariation(entity, i),
        }
    end
    for i = 0, 13 do
        skinData.props[#skinData.props + 1] = {
            prop_id = i,
            drawable = GetPedPropIndex(entity, i),
            texture = GetPedPropTextureIndex(entity, i),
        }
    end
    appearanceBackup = skinData
    return skinData
end

local function SetAppearance(ped, skinData)
    ped = ped or PlayerPedId()
    if type(skinData) ~= 'table' then return false end
    for _, v in pairs(skinData.components or {}) do
        if v.component_id then
            SetPedComponentVariation(ped, v.component_id, v.drawable, v.texture, 0)
        end
    end
    for _, v in pairs(skinData.props or {}) do
        if v.prop_id then
            SetPedPropIndex(ped, v.prop_id, v.drawable, v.texture, false)
        end
    end
    return true
end

local function RestoreAppearance(ped)
    if not appearanceBackup then return false end
    return SetAppearance(ped or PlayerPedId(), appearanceBackup)
end

olink._registerDefault('clothing', {
    GetResourceName = function() return '_default' end,
    OpenMenu = function() end,

    IsMale = function()
        local ped = PlayerPedId()
        if not DoesEntityExist(ped) then return false end
        return GetEntityModel(ped) == `mp_m_freemode_01`
    end,

    GetAppearance = GetAppearance,
    SetAppearance = SetAppearance,
    RestoreAppearance = RestoreAppearance,
})

if olink.callback then
    olink.callback.Register('o-link:clothing:getAppearance', function()
        return GetAppearance(PlayerPedId())
    end)
end

RegisterNetEvent('o-link:clothing:setAppearance', function(data)
    if source ~= '' and source ~= 65535 then return end
    SetAppearance(PlayerPedId(), data)
end)

RegisterNetEvent('o-link:clothing:restoreAppearance', function()
    if source ~= '' and source ~= 65535 then return end
    RestoreAppearance(PlayerPedId())
end)
