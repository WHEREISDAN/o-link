if not olink._guardImpl('Clothing', 'qb-clothing', 'qb-clothing') then return end
if not olink._hasOverride('Clothing') and GetResourceState('oxide-clothing') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('rcore_clothing') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('17mov_CharacterSystem') == 'started' then return end

-- qb-clothing uses named keys for components and props
local ComponentMap = {
    [1] = 'mask', [2] = 'hair', [3] = 'arms', [4] = 'pants', [5] = 'bag',
    [6] = 'shoes', [7] = 'accessory', [8] = 't-shirt', [9] = 'vest', [10] = 'decals', [11] = 'torso2',
}
local ComponentInverseMap = {
    mask = 1, hair = 2, arms = 3, pants = 4, bag = 5, shoes = 6,
    accessory = 7, ['t-shirt'] = 8, vest = 9, decals = 10, torso2 = 11,
}
local PropMap = {
    [0] = 'hat', [1] = 'glass', [2] = 'ear', [6] = 'watch', [7] = 'bracelet',
}
local PropInverseMap = {
    hat = 0, glass = 1, ear = 2, watch = 6, bracelet = 7,
}

local function convertComponentsFromDefault(defaultComponents)
    local result = {}
    for _, v in pairs(defaultComponents or {}) do
        local name = ComponentMap[v.component_id]
        if name then
            result[name] = { item = v.drawable, texture = v.texture }
        end
    end
    return result
end

local function convertComponentsToDefault(qbComponents)
    local result = {}
    for key, v in pairs(qbComponents or {}) do
        local id = ComponentInverseMap[key]
        if id then
            result[id] = { component_id = id, drawable = v.item, texture = v.texture }
        end
    end
    return result
end

local function convertPropsFromDefault(defaultProps)
    local result = {}
    for _, v in pairs(defaultProps or {}) do
        local name = PropMap[v.prop_id]
        if name then
            result[name] = { item = v.drawable, texture = v.texture }
        end
    end
    return result
end

local function convertPropsToDefault(qbProps)
    local result = {}
    for key, v in pairs(qbProps or {}) do
        local id = PropInverseMap[key]
        if id then
            result[#result + 1] = { prop_id = id, drawable = v.item, texture = v.texture }
        end
    end
    table.sort(result, function(a, b) return a.prop_id < b.prop_id end)
    return result
end

---@param qbSkin table flat qb skin table
---@return table {components, props}
function QbClothingConvertToDefault(qbSkin)
    return {
        components = convertComponentsToDefault(qbSkin),
        props = convertPropsToDefault(qbSkin),
    }
end

---@param defaultData table {components, props}
---@return table flat qb skin table
function QbClothingConvertFromDefault(defaultData)
    local components = convertComponentsFromDefault(defaultData.components)
    local props = convertPropsFromDefault(defaultData.props)
    for k, v in pairs(props) do
        components[k] = v
    end
    return components
end

-- Canonical head-overlay index -> qb-clothing flat key. qb reads the overlay
-- colour from `.texture` and hardcodes opacity, so only the colour is carried.
local OverlayToQb = {
    [1] = 'beard', [2] = 'eyebrows', [3] = 'ageing',
    [4] = 'makeup', [5] = 'blush', [8] = 'lipstick',
}

-- Canonical face-feature index -> qb-clothing flat key. qb stores value*10 and
-- divides by 10 on load (note the misspelled keys are intentional — qb's own).
local FeatureToQb = {
    [0] = 'nose_0', [1] = 'nose_1', [2] = 'nose_2', [3] = 'nose_3', [4] = 'nose_4',
    [5] = 'nose_5', [6] = 'eyebrown_high', [7] = 'eyebrown_forward', [8] = 'cheek_1',
    [9] = 'cheek_2', [10] = 'cheek_3', [11] = 'eye_opening', [12] = 'lips_thickness',
    [13] = 'jaw_bone_width', [14] = 'jaw_bone_back_lenght', [15] = 'chimp_bone_lowering',
    [16] = 'chimp_bone_lenght', [17] = 'chimp_bone_width', [18] = 'chimp_hole',
    [19] = 'neck_thikness',
}

-- Maps survive a JSON round-trip with either int or string keys.
local function pick(map, index)
    if type(map) ~= 'table' then return nil end
    return map[index] or map[tostring(index)]
end

-- Canonical overlay style is 1-based (0 = none); qb wants a 0-based index, 255 = none.
local function qbOverlayItem(style)
    style = tonumber(style) or 0
    if style <= 0 then return 255 end
    return style - 1
end

---Translate the native-indexed creator object into qb-clothing's flat HEAD skin:
---head blend, face features, head overlays, hair colour and eye colour. Clothing
---and props are produced separately by QbClothingConvertFromDefault. qb-clothing's
---loader indexes every one of these keys unconditionally, so all are emitted.
---@param data table canonical creator appearance
---@return table flat qb-clothing head fields
function QbClothingHeadFromCreator(data)
    data = data or {}
    local hb = data.headBlend or {}
    local hair = data.hair or {}

    local skin = {
        face  = { item = tonumber(hb.shapeFirst) or 0,  texture = tonumber(hb.skinFirst) or 0 },
        face2 = { item = tonumber(hb.shapeSecond) or 0, texture = tonumber(hb.skinSecond) or 0 },
        facemix = {
            shapeMix        = tonumber(hb.shapeMix) or 0.5,
            skinMix         = tonumber(hb.skinMix) or 0.5,
            defaultShapeMix = tonumber(hb.shapeMix) or 0.5,
            defaultSkinMix  = tonumber(hb.skinMix) or 0.5,
        },
        hair      = { item = tonumber(hair.style) or 0, texture = tonumber(hair.color) or 0 },
        eye_color = { item = tonumber(data.eyeColor) or 0, texture = 0 },
    }

    for index, key in pairs(OverlayToQb) do
        local ov = pick(data.overlays, index) or {}
        skin[key] = { item = qbOverlayItem(ov.style), texture = tonumber(ov.color) or 0 }
    end

    -- Moles/freckles (overlay 9) is the one overlay whose `.texture` is opacity*10.
    local moles = pick(data.overlays, 9) or {}
    local molesStyle = tonumber(moles.style) or 0
    skin.moles = {
        item = molesStyle > 0 and (molesStyle - 1) or 0,
        texture = math.floor(((tonumber(moles.opacity) or 0) * 10) + 0.5),
    }

    for index, key in pairs(FeatureToQb) do
        skin[key] = { item = (tonumber(pick(data.features, index)) or 0.0) * 10, texture = 0 }
    end

    return skin
end

---Translate a stored qb-clothing skin into the canonical appearance object (merge
---base for partial edits, e.g. a barbershop). Two skin shapes exist: pure qb-flat
---(from qb's own creator) and a hybrid that also carries illenium-shape keys. The
---hybrid is read through the illenium inverse, with hair taken from the qb keys
---(where the hybrid keeps it).
---@param skin table
---@return table canonical
function QbHeadToCanonical(skin)
    skin = type(skin) == 'table' and skin or {}
    local A = olink._appearance

    if type(skin.headOverlays) == 'table' or type(skin.headBlend) == 'table' then
        local canonical = OlinkIlleniumToCanonical(skin)
        canonical.framework = 'qb-clothing'
        -- The hybrid stores hair in qb shape ({ item, texture }), not illenium.
        if type(skin.hair) == 'table' and skin.hair.style == nil then
            canonical.hair = {
                style = tonumber(skin.hair.item) or 0, texture = 0,
                color = tonumber(skin.hair.texture) or 0, highlight = 0,
            }
        end
        return canonical
    end

    -- Pure qb-flat skin.
    local default = QbClothingConvertToDefault(skin)
    local canonical = {
        framework = 'qb-clothing',
        components = A.componentsToMap(default.components),
        props = A.propsToMap(default.props),
        features = {},
        overlays = {},
    }

    if type(skin.hair) == 'table' then
        canonical.hair = {
            style = tonumber(skin.hair.item) or 0, texture = 0,
            color = tonumber(skin.hair.texture) or 0, highlight = 0,
        }
    end
    if type(skin.eye_color) == 'table' then
        canonical.eyeColor = tonumber(skin.eye_color.item) or 0
    end
    if type(skin.face) == 'table' then
        canonical.headBlend = {
            shapeFirst = tonumber(skin.face.item) or 0,
            skinFirst = tonumber(skin.face.texture) or 0,
            shapeSecond = type(skin.face2) == 'table' and tonumber(skin.face2.item) or 0,
            skinSecond = type(skin.face2) == 'table' and tonumber(skin.face2.texture) or 0,
            shapeMix = type(skin.facemix) == 'table' and tonumber(skin.facemix.shapeMix) or 0.5,
            skinMix = type(skin.facemix) == 'table' and tonumber(skin.facemix.skinMix) or 0.5,
        }
    end

    -- Overlays (qb stores colour only; opacity isn't persisted, so default to 1).
    for index, key in pairs(OverlayToQb) do
        local ov = skin[key]
        if type(ov) == 'table' then
            local item = tonumber(ov.item)
            canonical.overlays[index] = {
                style = (not item or item == 255) and 0 or (item + 1),
                opacity = 1.0,
                color = tonumber(ov.texture) or 0,
                secondColor = 0,
            }
        end
    end
    if type(skin.moles) == 'table' then
        local item = tonumber(skin.moles.item) or 0
        canonical.overlays[9] = {
            style = item > 0 and (item + 1) or 0,
            opacity = (tonumber(skin.moles.texture) or 0) / 10,
            color = 0, secondColor = 0,
        }
    end
    for index, key in pairs(FeatureToQb) do
        local f = skin[key]
        if type(f) == 'table' and f.item ~= nil then
            canonical.features[index] = (tonumber(f.item) or 0) / 10
        end
    end

    return canonical
end
