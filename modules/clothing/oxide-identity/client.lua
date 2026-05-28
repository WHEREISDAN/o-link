if not olink._guardImpl('Clothing', 'oxide-identity', 'oxide-identity') then return end

local componentApplyOrder = { 0, 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 8 }

local function resolveModelName(ped, sbModel)
    if type(sbModel) == 'string' and #sbModel > 0 then return sbModel end
    local hash = GetEntityModel(ped)
    if hash == `mp_m_freemode_01` then return 'mp_m_freemode_01' end
    if hash == `mp_f_freemode_01` then return 'mp_f_freemode_01' end
    return tostring(hash)
end

local function applyComponentsAndPropsNative(ped, components, props)
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

olink._register('clothing', {
    ---@return string
    GetResourceName = function()
        return 'oxide-identity'
    end,

    OpenMenu = function()
        exports['oxide-identity']:OpenClothing()
    end,

    -- Open the appearance creator for a brand-new character. The framework
    -- persists the result to the active character; onDone(success) fires after.
    StartCreation = function(gender, onDone)
        -- Let the creator set a fresh freemode model for the chosen gender.
        exports['oxide-identity']:OpenCreator(gender, function(appearance)
            if appearance then
                TriggerServerEvent('o-link:clothing:saveCreationAppearance', appearance)
            end
            if onDone then onDone(appearance ~= nil) end
        end)
    end,

    -- Apply the loaded character's stored appearance to the player ped. On
    -- frameworks whose clothing resource applies on load this is a no-op.
    ApplyPlayerAppearance = function()
        exports['oxide-identity']:ApplyAll()
    end,

    -- Returns a full-fidelity snapshot of the player's appearance:
    --   * _default-shape `components` + `props` for backward-compat consumers
    --   * `framework = 'oxide-identity'` marker so SetAppearance knows which
    --     apply path to take
    --   * `face` (headBlend + features + overlays), `hair`, `eyeColor`, `tattoos`
    --     for the rich appearance the framework persists in state bags.
    GetAppearance = function(ped)
        ped = ped or PlayerPedId()
        local sb = LocalPlayer and LocalPlayer.state or nil
        local appearance = (sb and sb['oxide:appearance']) or {}
        local clothing = (sb and sb['oxide:clothing']) or {}
        local tattoos = (sb and sb['oxide:tattoos']) or {}

        local defaultShape = OxideIdentityConvertToDefault(clothing)

        return {
            model = resolveModelName(ped, appearance.model),
            components = defaultShape.components,
            props = defaultShape.props,
            framework = 'oxide-identity',
            face = appearance.face,
            hair = appearance.hair,
            eyeColor = appearance.eyeColor,
            tattoos = tattoos,
        }
    end,

    -- Applies an appearance snapshot to any ped. When the payload was captured
    -- from oxide-identity (`framework == 'oxide-identity'`), routes through
    -- ApplyClothingToPed / ApplyAppearanceToPed which know how to unwrap the
    -- nested `face` shape and set head blend / hair color / etc. correctly.
    -- For cross-framework payloads, falls back to native component/prop apply.
    SetAppearance = function(ped, data)
        ped = ped or PlayerPedId()
        if type(data) ~= 'table' then return false end

        if data.framework == 'oxide-identity' then
            local clothingForOxide = OxideIdentityConvertFromDefault({
                components = data.components,
                props = data.props,
            })
            pcall(function() exports['oxide-identity']:ApplyClothingToPed(ped, clothingForOxide) end)
            pcall(function()
                exports['oxide-identity']:ApplyAppearanceToPed(ped, {
                    headBlend = data.face and data.face.headBlend,
                    features  = data.face and data.face.features,
                    overlays  = data.face and data.face.overlays,
                    eyeColor  = data.eyeColor,
                    hair      = data.hair,
                })
            end)
            if type(data.tattoos) == 'table' then
                ClearPedDecorations(ped)
                for _, t in ipairs(data.tattoos) do
                    if t.collection and t.name then
                        AddPedDecorationFromHashes(ped, GetHashKey(t.collection), GetHashKey(t.name))
                    end
                end
            end
            return true
        end

        applyComponentsAndPropsNative(ped, data.components, data.props)
        return true
    end,
})

RegisterNetEvent('o-link:client:clothing:openMenu', function()
    exports['oxide-identity']:OpenClothing()
end)

RegisterNetEvent('o-link:client:clothing:setAppearance', function(data)
    exports['oxide-identity']:ApplyClothing(OxideIdentityConvertFromDefault(data))
end)
