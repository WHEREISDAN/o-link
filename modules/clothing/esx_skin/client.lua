if not olink._guardImpl('Clothing', 'esx_skin', 'esx_skin') then return end
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
    GetResourceName = function() return 'esx_skin' end,

    OpenMenu = function()
        TriggerEvent('esx_skin:openMenu', function() end, function() end, true)
    end,

    -- Opens esx_skin's saveable menu. esx_skin's openSaveableMenu accepts
    -- submit/cancel callbacks; we wire them straight into onDone. Default-sex
    -- skin is loaded via skinchanger first so the editor starts on a clean
    -- freemode model for the chosen gender.
    StartCreation = function(gender, onDone)
        local model = gender == 1 and 'mp_f_freemode_01' or 'mp_m_freemode_01'
        TriggerEvent('skinchanger:loadDefaultModel', gender == 1, function()
            TriggerEvent('esx_skin:openSaveableMenu',
                function() if onDone then onDone(true) end end,
                function() if onDone then onDone(false) end end
            )
        end)
    end,

    -- esx_skin loads the saved skin on `esx:playerLoaded` via skinchanger's
    -- own handler, so this is a no-op in normal flow.
    ApplyPlayerAppearance = function()
        return true
    end,

    GetAppearance = function(ped)
        ped = ped or PlayerPedId()
        return {
            framework = 'esx_skin',
            model = resolveModelName(ped),
            components = {},
            props = {},
        }
    end,

    -- Apply a default-shape snapshot to any ped. skinchanger only operates on
    -- the local player ped, so for the LOCAL player with an esx_skin-tagged
    -- payload we route through it; for preview peds we fall back to the
    -- native default-shape applier (head-blend fidelity is lost but
    -- components/props render correctly).
    SetAppearance = function(ped, data)
        ped = ped or PlayerPedId()
        if type(data) ~= 'table' then return false end

        if data.framework == 'esx_skin' and ped == PlayerPedId() and type(data.skin) == 'table' then
            TriggerEvent('skinchanger:loadSkin', data.skin)
            return true
        end

        applyDefaultShape(ped, data.components, data.props)
        return true
    end,
})

RegisterNetEvent('o-link:client:clothing:setAppearance', function(data)
    TriggerEvent('o-link:clothing:applyAppearance', data)
end)
