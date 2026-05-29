if not olink._guardImpl('Clothing', 'illenium-appearance', 'illenium-appearance') then return end
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
    GetResourceName = function() return 'illenium-appearance' end,

    OpenMenu = function()
        TriggerEvent('qb-clothing:client:openMenu')
    end,

    -- Opens illenium-appearance's first-character editor. The framework's
    -- own NUI handles save + DB persist via the `illenium-appearance:server:
    -- saveAppearance` event. onDone fires immediately so multichar can show
    -- the welcome toast; the player completes customization in the editor.
    StartCreation = function(gender, onDone)
        TriggerEvent('qb-clothes:client:CreateFirstCharacter')
        if onDone then onDone(true) end
    end,

    -- illenium-appearance applies the saved skin automatically on its own
    -- player-loaded hook, so there is nothing to do here.
    ApplyPlayerAppearance = function()
        return true
    end,

    -- Cross-framework preview snapshot of the local player ped. Rich
    -- illenium fields aren't surfaced here because consumer SetAppearance
    -- falls back to the native default-shape applier for cross-framework
    -- payloads.
    GetAppearance = function(ped)
        ped = ped or PlayerPedId()
        return {
            framework = 'illenium-appearance',
            model = resolveModelName(ped),
            components = {},
            props = {},
        }
    end,

    -- Apply a default-shape snapshot to any ped. illenium's setPedAppearance
    -- works on any freemode ped (it guards head blend internally), so we
    -- route through it for full fidelity on preview peds AND the local player
    -- whenever the payload is illenium-tagged. Cross-framework payloads fall
    -- back to the native default-shape applier.
    SetAppearance = function(ped, data)
        ped = ped or PlayerPedId()
        if type(data) ~= 'table' then return false end

        if data.framework == 'illenium-appearance' then
            local ok = pcall(function()
                exports['illenium-appearance']:setPedAppearance(ped, data)
            end)
            if ok then return true end
        end

        applyDefaultShape(ped, data.components, data.props)
        return true
    end,
})

RegisterNetEvent('o-link:client:clothing:setAppearance', function(data)
    TriggerEvent('o-link:clothing:applyAppearance', data)
end)
