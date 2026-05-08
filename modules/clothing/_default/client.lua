-- Always loaded so the native ped applier is available regardless of which
-- framework clothing resource is also present. Framework adapters override
-- OpenMenu / IsMale; the SetAppearance event listener below is the only thing
-- that actually moves the ped on a server-triggered change.
if not olink._guardImpl('Clothing', '_default', false) then return end

local appearanceBackup
local componentApplyOrder = { 0, 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 8 }

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
    local componentsById = {}
    for key, value in pairs(skinData.components or {}) do
        local componentId = tonumber(value and value.component_id) or tonumber(key)
        if componentId then
            componentsById[componentId] = value
        end
    end
    for _, componentId in ipairs(componentApplyOrder) do
        local v = componentsById[componentId]
        if v then
            SetPedComponentVariation(ped, componentId, tonumber(v.drawable) or 0, tonumber(v.texture) or 0, 0)
            componentsById[componentId] = nil
        end
    end
    for componentId, v in pairs(componentsById) do
        if v then
            SetPedComponentVariation(ped, componentId, tonumber(v.drawable) or 0, tonumber(v.texture) or 0, 0)
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

RegisterNetEvent('o-link:client:clothing:setAppearance', function(data)
    SetAppearance(PlayerPedId(), data)
end)

RegisterNetEvent('o-link:client:clothing:restoreAppearance', function()
    RestoreAppearance(PlayerPedId())
end)
