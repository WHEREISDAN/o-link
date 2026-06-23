if not olink._guardImpl('Clothing', 'esx_skin', 'esx_skin') then return end
if not olink._hasOverride('Clothing') and GetResourceState('rcore_clothing') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('17mov_CharacterSystem') == 'started' then return end

-- esx_skin component map: componentId -> name suffix used in ESX skin keys
local ComponentMap = {
    [1] = 'mask', [2] = 'ears', [3] = 'arms', [4] = 'pants', [5] = 'bags',
    [6] = 'shoes', [7] = 'chain', [8] = 'tshirt', [9] = 'bproof', [10] = 'decals', [11] = 'torso',
}
local ComponentInverseMap = {
    mask = 1, arms = 3, pants = 4, bags = 5, shoes = 6,
    chain = 7, tshirt = 8, bproof = 9, decals = 10, torso = 11,
}
local PropMap = {
    [0] = 'helmet', [1] = 'glasses', [2] = 'ears', [6] = 'watches', [7] = 'bracelets',
}
local PropInverseMap = {
    helmet_1 = 0, helmet_2 = 0, glasses_1 = 1, glasses_2 = 1,
    ears_1 = 2, ears_2 = 2, watches_1 = 6, watches_2 = 6, bracelets_1 = 7, bracelets_2 = 7,
}

local function ConvertComponentsFromDefault(defaultComponents)
    local result = {}
    for _, componentData in pairs(defaultComponents or {}) do
        local name = ComponentMap[componentData.component_id]
        if name then
            result[name .. '_1'] = componentData.drawable
            result[name .. '_2'] = componentData.texture
        end
    end
    return result
end

local function ConvertComponentsToDefault(esxComponents)
    local result = {}
    for key, val in pairs(esxComponents or {}) do
        local isTexture = key:find('_2')
        local baseName = key:gsub('_1', ''):gsub('_2', '')
        local id = ComponentInverseMap[baseName]
        if id then
            result[id] = result[id] or {}
            result[id].component_id = id
            if isTexture then
                result[id].texture = val
            else
                result[id].drawable = val
                result[id].texture = result[id].texture or 0
            end
        end
    end
    return result
end

local function ConvertPropsFromDefault(defaultProps)
    local result = {}
    for _, propData in pairs(defaultProps or {}) do
        local name = PropMap[propData.prop_id]
        if name then
            result[name .. '_1'] = propData.drawable
            result[name .. '_2'] = propData.texture
        end
    end
    return result
end

local function ConvertPropsToDefault(esxProps)
    local result = {}
    for key, val in pairs(esxProps or {}) do
        local isTexture = key:find('_2')
        local baseName = key:gsub('_1', ''):gsub('_2', '')
        local id = PropInverseMap[key]
        if id then
            result[id] = result[id] or {}
            if isTexture then
                result[id].texture = val
            else
                result[id].prop_id = id
                result[id].drawable = val
                result[id].texture = result[id].texture or 0
            end
        end
    end
    local sorted = {}
    for _, v in pairs(result) do sorted[#sorted + 1] = v end
    table.sort(sorted, function(a, b) return a.prop_id < b.prop_id end)
    return sorted
end

---Convert esx_skin flat skin table to default {components, props} format
---@param esxSkin table
---@return table
function EsxSkinConvertToDefault(esxSkin)
    return {
        components = ConvertComponentsToDefault(esxSkin),
        props = ConvertPropsToDefault(esxSkin),
    }
end

---Convert default {components, props} to esx_skin flat skin table
---@param defaultData table
---@return table
function EsxSkinConvertFromDefault(defaultData)
    local components = ConvertComponentsFromDefault(defaultData.components)
    local props = ConvertPropsFromDefault(defaultData.props)
    for k, v in pairs(props) do
        components[k] = v
    end
    return components
end

-- ── Rich appearance (skinchanger flat skin) <-> canonical ────────────────────
-- skinchanger stores the full appearance in the same flat `users.skin` table the
-- adapter already reads. These converters surface hair / overlays / head blend /
-- features so a barbershop can read + persist them. Canonical overlay style is
-- 1-based (0 = none); skinchanger stores the raw SetPedHeadOverlay index (255 =
-- none) and opacity as 0-10. Head overlay -> flat key groups (index 0-10):
local ESX_OVERLAYS = {
    [0]  = { 'blemishes_1', 'blemishes_2' },
    [1]  = { 'beard_1', 'beard_2', 'beard_3', 'beard_4' },
    [2]  = { 'eyebrows_1', 'eyebrows_2', 'eyebrows_3', 'eyebrows_4' },
    [3]  = { 'age_1', 'age_2' },
    [4]  = { 'makeup_1', 'makeup_2', 'makeup_3', 'makeup_4' },
    [5]  = { 'blush_1', 'blush_2', 'blush_3' },
    [6]  = { 'complexion_1', 'complexion_2' },
    [7]  = { 'sun_1', 'sun_2' },
    [8]  = { 'lipstick_1', 'lipstick_2', 'lipstick_3', 'lipstick_4' },
    [9]  = { 'moles_1', 'moles_2' },
    [10] = { 'chest_1', 'chest_2', 'chest_3' },
}

-- Canonical face-feature index (0-19) -> flat key, in SetPedFaceFeature order.
local ESX_FEATURES = {
    [0] = 'nose_1', [1] = 'nose_2', [2] = 'nose_3', [3] = 'nose_4', [4] = 'nose_5',
    [5] = 'nose_6', [6] = 'eyebrows_5', [7] = 'eyebrows_6', [8] = 'cheeks_1',
    [9] = 'cheeks_2', [10] = 'cheeks_3', [11] = 'eye_squint', [12] = 'lip_thickness',
    [13] = 'jaw_1', [14] = 'jaw_2', [15] = 'chin_1', [16] = 'chin_2', [17] = 'chin_3',
    [18] = 'chin_4', [19] = 'neck_thickness',
}

---Convert an esx_skin / skinchanger flat skin into the canonical appearance object.
---@param skin table flat skinchanger skin
---@return table canonical
function EsxSkinToCanonical(skin)
    skin = type(skin) == 'table' and skin or {}
    local A = olink._appearance
    local default = EsxSkinConvertToDefault(skin)
    local canonical = {
        framework = 'esx_skin',
        model = (tonumber(skin.sex) == 1) and 'mp_f_freemode_01' or 'mp_m_freemode_01',
        components = A.componentsToMap(default.components),
        props = A.propsToMap(default.props),
        features = {},
        overlays = {},
        eyeColor = tonumber(skin.eye_color) or 0,
        hair = {
            style = tonumber(skin.hair_1) or 0,
            texture = tonumber(skin.hair_2) or 0,
            color = tonumber(skin.hair_color_1) or 0,
            highlight = tonumber(skin.hair_color_2) or 0,
        },
        headBlend = {
            shapeFirst = tonumber(skin.mom) or 0,
            shapeSecond = tonumber(skin.dad) or 0,
            skinFirst = tonumber(skin.mom) or 0,
            skinSecond = tonumber(skin.dad) or 0,
            shapeMix = (tonumber(skin.face_md_weight) or 0) / 100,
            skinMix = (tonumber(skin.skin_md_weight) or 0) / 100,
        },
    }

    for index, keys in pairs(ESX_OVERLAYS) do
        local styleVal = tonumber(skin[keys[1]])
        if styleVal ~= nil then
            canonical.overlays[index] = {
                style = (styleVal == 255) and 0 or (styleVal + 1),
                opacity = (tonumber(skin[keys[2]]) or 0) / 10,
                color = keys[3] and tonumber(skin[keys[3]]) or 0,
                secondColor = keys[4] and tonumber(skin[keys[4]]) or 0,
            }
        end
    end

    for index, key in pairs(ESX_FEATURES) do
        if skin[key] ~= nil then canonical.features[index] = (tonumber(skin[key]) or 0) / 10 end
    end

    return canonical
end

---Convert canonical styling fields into a PARTIAL flat skin (hair / overlays /
---eye colour only). Merge this over the stored skin so head blend, face features
---and clothing are preserved untouched.
---@param canonical table
---@return table partial flat skin
function CanonicalToEsxFlat(canonical)
    canonical = type(canonical) == 'table' and canonical or {}
    local flat = {}

    local hair = canonical.hair
    if type(hair) == 'table' then
        if hair.style ~= nil then flat.hair_1 = tonumber(hair.style) or 0 end
        if hair.texture ~= nil then flat.hair_2 = tonumber(hair.texture) or 0 end
        if hair.color ~= nil then flat.hair_color_1 = tonumber(hair.color) or 0 end
        if hair.highlight ~= nil then flat.hair_color_2 = tonumber(hair.highlight) or 0 end
    end

    if canonical.eyeColor ~= nil then flat.eye_color = tonumber(canonical.eyeColor) or 0 end

    if type(canonical.overlays) == 'table' then
        for index, keys in pairs(ESX_OVERLAYS) do
            local ov = canonical.overlays[index] or canonical.overlays[tostring(index)]
            if type(ov) == 'table' then
                local style = tonumber(ov.style) or 0
                flat[keys[1]] = (style == 0) and 255 or (style - 1)
                flat[keys[2]] = math.floor(((tonumber(ov.opacity) or 0) * 10) + 0.5)
                if keys[3] then flat[keys[3]] = tonumber(ov.color) or 0 end
                if keys[4] then flat[keys[4]] = tonumber(ov.secondColor) or 0 end
            end
        end
    end

    return flat
end
