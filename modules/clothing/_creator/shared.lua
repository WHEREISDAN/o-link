-- Canonical creator appearance translation.
--
-- oxide-multichar's built-in creator emits a native-indexed appearance object
-- (the same shape oxide-identity uses): face features keyed 0-19, head overlays
-- keyed 0-12 with a 1-based style (0 = none), and components/props as
-- { [id] = { drawable, texture } } maps. illenium-appearance / fivem-appearance /
-- qb-clothing all persist the richer illenium-style `skin` object instead, so the
-- adapters that write to `playerskins` translate the canonical object through here.
--
-- Loaded as a shared script (no guard) so the helpers exist for every adapter.

-- Face feature index -> illenium key (SetPedFaceFeature order, 0-19).
local FEATURE_KEYS = {
    [0] = 'noseWidth', [1] = 'nosePeakHigh', [2] = 'nosePeakSize', [3] = 'noseBoneHigh',
    [4] = 'nosePeakLowering', [5] = 'noseBoneTwist', [6] = 'eyeBrownHigh', [7] = 'eyeBrownForward',
    [8] = 'cheeksBoneHigh', [9] = 'cheeksBoneWidth', [10] = 'cheeksWidth', [11] = 'eyesOpening',
    [12] = 'lipsThickness', [13] = 'jawBoneWidth', [14] = 'jawBoneBackSize', [15] = 'chinBoneLowering',
    [16] = 'chinBoneLenght', [17] = 'chinBoneSize', [18] = 'chinHole', [19] = 'neckThickness',
}

-- Head overlay index -> illenium key (0-11; index 12 has no illenium equivalent).
local OVERLAY_KEYS = {
    [0] = 'blemishes', [1] = 'beard', [2] = 'eyebrows', [3] = 'ageing', [4] = 'makeUp',
    [5] = 'blush', [6] = 'complexion', [7] = 'sunDamage', [8] = 'lipstick',
    [9] = 'moleAndFreckles', [10] = 'chestHair', [11] = 'bodyBlemishes',
}

-- Convert a { [id] = { drawable, texture } } map (string or int keys after a JSON
-- round-trip) into illenium's array form: { { component_id|prop_id, drawable, texture } }.
local function mapToArray(map, idKey)
    local out = {}
    for k, v in pairs(map or {}) do
        local id = tonumber(v and v.component_id) or tonumber(v and v.prop_id) or tonumber(k)
        if id and v then
            out[#out + 1] = {
                [idKey] = id,
                drawable = tonumber(v.drawable) or 0,
                texture = tonumber(v.texture) or 0,
            }
        end
    end
    table.sort(out, function(a, b) return a[idKey] < b[idKey] end)
    return out
end

-- Creator tattoos carry the already gender-resolved decoration name. Emit it under
-- every key the various appearance resources read (name / hash / hashName) so the
-- decoration re-applies on load regardless of which one the backend uses.
local function mapTattoos(tattoos)
    local out = {}
    for _, t in ipairs(tattoos or {}) do
        local hash = t.name
        out[#out + 1] = {
            collection = t.collection,
            name = hash,
            hash = hash,
            hashName = hash,
            zone = t.zone,
            label = t.label,
        }
    end
    return out
end

---Translate the native-indexed creator object into an illenium-shape skin table.
---@param data table canonical creator appearance
---@return table skin illenium-style appearance object
function OlinkCreatorToIllenium(data)
    data = data or {}
    local hb = data.headBlend or {}

    local headBlend = {
        shapeFirst = tonumber(hb.shapeFirst) or 0,
        shapeSecond = tonumber(hb.shapeSecond) or 0,
        shapeThird = 0,
        skinFirst = tonumber(hb.skinFirst) or 0,
        skinSecond = tonumber(hb.skinSecond) or 0,
        skinThird = 0,
        shapeMix = tonumber(hb.shapeMix) or 0.5,
        skinMix = tonumber(hb.skinMix) or 0.5,
        thirdMix = 0.0,
    }

    local faceFeatures = {}
    for index, name in pairs(FEATURE_KEYS) do
        local raw = data.features and (data.features[index] or data.features[tostring(index)])
        faceFeatures[name] = (tonumber(raw) or 0.0) + 0.0
    end

    local headOverlays = {}
    for index, name in pairs(OVERLAY_KEYS) do
        local ov = data.overlays and (data.overlays[index] or data.overlays[tostring(index)])
        ov = ov or {}
        local style = tonumber(ov.style) or 0
        headOverlays[name] = {
            -- canonical style 0 = none -> illenium 255; otherwise 0-based index.
            style = style == 0 and 255 or (style - 1),
            opacity = (tonumber(ov.opacity) or 0.0) + 0.0,
            color = tonumber(ov.color) or 0,
            secondColor = tonumber(ov.secondColor) or 0,
        }
    end

    local hair = data.hair or {}

    return {
        model = data.model or 'mp_m_freemode_01',
        headBlend = headBlend,
        faceFeatures = faceFeatures,
        headOverlays = headOverlays,
        hair = {
            style = tonumber(hair.style) or 0,
            texture = tonumber(hair.texture) or 0,
            color = tonumber(hair.color) or 0,
            highlight = tonumber(hair.highlight) or 0,
        },
        eyeColor = tonumber(data.eyeColor) or 0,
        components = mapToArray(data.components, 'component_id'),
        props = mapToArray(data.props, 'prop_id'),
        tattoos = mapTattoos(data.tattoos),
    }
end
