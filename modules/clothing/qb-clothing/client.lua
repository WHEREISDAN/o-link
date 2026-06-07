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

    -- Apply a snapshot to any ped (preview or player). When the payload carries a
    -- qb-clothing flat-skin blob we route through qb-clothing's loadPlayerClothing
    -- event, which is ped-agnostic and applies the FULL look (head blend, face
    -- features, overlays, hair + clothing) to whatever ped is passed — so preview
    -- peds get skin data, not just clothing. Without a skin blob we fall back to
    -- the native default-shape applier (clothing components/props only).
    SetAppearance = function(ped, data)
        ped = ped or PlayerPedId()
        if type(data) ~= 'table' then return false end

        -- loadPlayerClothing indexes flat skin keys (face, nose_*, overlays...)
        -- unconditionally, so only route there when the blob is actually flat
        -- (has `face`). Older/foreign payloads without it fall back to the
        -- clothing-only applier rather than erroring mid-render.
        if data.framework == 'qb-clothing' and type(data.skin) == 'table' and data.skin.face ~= nil then
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
