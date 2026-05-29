if not olink._guardImpl('Clothing', 'qb-clothing', 'qb-clothing') then return end
if not olink._hasOverride('Clothing') and GetResourceState('oxide-clothing') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('rcore_clothing') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('17mov_CharacterSystem') == 'started' then return end

local componentApplyOrder = { 0, 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 8 }

local function applyDefaultShape(ped, components, props)
    if type(components) == 'table' then
        local byId = {}
        for k, v in pairs(components) do
            local id = tonumber(v and v.component_id) or tonumber(k)
            if id then byId[id] = v end
        end
        for _, id in ipairs(componentApplyOrder) do
            local v = byId[id]
            if v then
                SetPedComponentVariation(ped, id, tonumber(v.drawable) or 0, tonumber(v.texture) or 0, 0)
                byId[id] = nil
            end
        end
        for id, v in pairs(byId) do
            SetPedComponentVariation(ped, id, tonumber(v.drawable) or 0, tonumber(v.texture) or 0, 0)
        end
    end
    if type(props) == 'table' then
        for _, v in pairs(props) do
            if v.prop_id ~= nil then
                SetPedPropIndex(ped, v.prop_id, tonumber(v.drawable) or -1, tonumber(v.texture) or 0, false)
            end
        end
    end
end

local function resolveModelName(ped)
    local hash = GetEntityModel(ped)
    if hash == `mp_m_freemode_01` then return 'mp_m_freemode_01' end
    if hash == `mp_f_freemode_01` then return 'mp_f_freemode_01' end
    return tostring(hash)
end

olink._register('clothing', {
    GetResourceName = function() return 'qb-clothing' end,

    OpenMenu = function()
        TriggerEvent('qb-clothing:client:openMenu')
    end,

    -- Opens qb-clothing's first-character editor. The framework's own NUI
    -- handles save + DB persist via `qb-clothing:saveSkin`. onDone fires
    -- immediately so multichar can show the welcome toast.
    StartCreation = function(gender, onDone)
        TriggerEvent('qb-clothes:client:CreateFirstCharacter')
        if onDone then onDone(true) end
    end,

    -- qb-clothing applies the saved skin automatically on `QBCore:Client:
    -- OnPlayerLoaded` via `qb-clothing:client:loadPlayerClothing`.
    ApplyPlayerAppearance = function()
        return true
    end,

    GetAppearance = function(ped)
        ped = ped or PlayerPedId()
        return {
            framework = 'qb-clothing',
            model = resolveModelName(ped),
            components = {},
            props = {},
        }
    end,

    -- Apply a default-shape snapshot to any ped (preview or player). For a
    -- qb-clothing-tagged payload on the LOCAL player we route through
    -- qb-clothing's loadPlayerClothing event (full flat-skin); for everything
    -- else we use the native default-shape applier.
    SetAppearance = function(ped, data)
        ped = ped or PlayerPedId()
        if type(data) ~= 'table' then return false end

        if data.framework == 'qb-clothing' and ped == PlayerPedId() and type(data.skin) == 'table' then
            TriggerEvent('qb-clothing:client:loadPlayerClothing', data.skin, ped)
            return true
        end

        applyDefaultShape(ped, data.components, data.props)
        return true
    end,
})

RegisterNetEvent('o-link:client:clothing:setAppearance', function(data)
    TriggerEvent('o-link:clothing:applyAppearance', data)
end)
