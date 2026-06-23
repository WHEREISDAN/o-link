if not olink._guardImpl('Clothing', 'rcore_clothing', 'rcore_clothing') then return end
if not olink._hasOverride('Clothing') and GetResourceState('17mov_CharacterSystem') == 'started' then return end

-- rcore_clothing stores a "current outfit" JSON keyed by identifier. Its encoding
-- (verified against rcore's own illenium->rcore migration) is:
--   components = { ["3"] = "3_20_0", ... }          -- "componentId_drawable_texture"
--   props      = { ["1"] = "101_5_5", ... }         -- "(propId+100)_drawable_texture"
--   hair       = { color1, color2, id = "2_<style>_0" }
--   headOverlay= { ["1"] = { id=<style 0-based,255=none>, opacity, color1, color2 } }
--   headblend  = { maleModel, femaleModel, maleTone, femaleTone, modelBlend, toneBlend }
--   faceFeatures = { ["0"]=val, ... }
--   eyeColor   = number
-- Tattoos are NOT part of this skin (rcore handles them via rcore_tattoos), so
-- they are dropped on the way in and out.

local function splitTriplet(value)
    if type(value) ~= 'string' then return nil end
    local a, b, c = value:match('^(%-?%d+)_(%-?%d+)_(%-?%d+)$')
    if not a then return nil end
    return tonumber(a), tonumber(b), tonumber(c)
end

local function modelName(pedModel)
    if pedModel == `mp_f_freemode_01` or pedModel == 'mp_f_freemode_01' then return 'mp_f_freemode_01' end
    return 'mp_m_freemode_01'
end

---Decode an rcore current-outfit table into the canonical appearance object.
---@param outfit table|nil
---@param pedModel any rcore stores the ped model hash alongside the outfit
---@return table canonical
function RcoreToCanonical(outfit, pedModel)
    outfit = type(outfit) == 'table' and outfit or {}
    local canonical = {
        framework = 'rcore_clothing',
        model = modelName(pedModel),
        components = {},
        props = {},
        overlays = {},
        features = {},
    }

    -- Components (skip 2; hair owns it).
    if type(outfit.components) == 'table' then
        for k, v in pairs(outfit.components) do
            local c, d, t = splitTriplet(v)
            local id = c or tonumber(k)
            if id and id ~= 2 then
                canonical.components[id] = { drawable = d or 0, texture = t or 0 }
            end
        end
        local hc, hd, ht = splitTriplet(outfit.components['2'] or outfit.components[2])
        if hc then
            canonical.hair = canonical.hair or {}
            canonical.hair.style = hd or 0
            canonical.hair.texture = ht or 0
        end
    end

    -- Props (key is the prop id; value is "(id+100)_drawable_texture").
    if type(outfit.props) == 'table' then
        for k, v in pairs(outfit.props) do
            local p, d, t = splitTriplet(v)
            local id = tonumber(k) or (p and (p - 100))
            if id then
                canonical.props[id] = { drawable = d or -1, texture = t or 0 }
            end
        end
    end

    -- Hair colour/highlight.
    if type(outfit.hair) == 'table' then
        canonical.hair = canonical.hair or {}
        canonical.hair.color = tonumber(outfit.hair.color1) or 0
        canonical.hair.highlight = tonumber(outfit.hair.color2) or 0
        if canonical.hair.style == nil then
            local _, style = splitTriplet(outfit.hair.id)
            canonical.hair.style = style or 0
            canonical.hair.texture = canonical.hair.texture or 0
        end
    end

    -- Head overlays: rcore style is 0-based (255 = none); canonical is 1-based (0 = none).
    if type(outfit.headOverlay) == 'table' then
        for k, v in pairs(outfit.headOverlay) do
            local id = tonumber(k)
            if id and type(v) == 'table' then
                local style = tonumber(v.id)
                canonical.overlays[id] = {
                    style = (not style or style == 255) and 0 or (style + 1),
                    opacity = tonumber(v.opacity) or 1.0,
                    color = tonumber(v.color1) or 0,
                    secondColor = tonumber(v.color2) or 0,
                }
            end
        end
    end

    if type(outfit.headblend) == 'table' then
        local hb = outfit.headblend
        canonical.headBlend = {
            shapeFirst = tonumber(hb.maleModel) or 0,
            shapeSecond = tonumber(hb.femaleModel) or 0,
            skinFirst = tonumber(hb.maleTone) or 0,
            skinSecond = tonumber(hb.femaleTone) or 0,
            shapeMix = tonumber(hb.modelBlend) or 0.5,
            skinMix = tonumber(hb.toneBlend) or 0.5,
        }
    end

    if type(outfit.faceFeatures) == 'table' then
        for k, v in pairs(outfit.faceFeatures) do
            local id = tonumber(k)
            if id then canonical.features[id] = tonumber(v) or 0.0 end
        end
    end

    canonical.eyeColor = tonumber(outfit.eyeColor) or 0
    return canonical
end
