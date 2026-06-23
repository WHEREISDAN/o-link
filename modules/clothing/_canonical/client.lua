-- Generic canonical appearance applier (client).
--
-- Applies a canonical (or legacy {components, props}) appearance to the local
-- player ped via the `o-link:clothing:applyAppearance` event that adapters fire
-- after a server-side SetAppearance, using the same native sequence as the
-- multichar creator.
--
-- Components/props always apply. Rich fields (hair, overlays, headBlend,
-- features, eyeColor, tattoos) apply only when present in the canonical shape,
-- so a bare clothing payload leaves the face/hair untouched.

local A = olink._appearance

-- Overlay color routing: hair-type colors (1) vs makeup-type colors (2).
local HAIR_COLOR_OVERLAYS = { [1] = true, [2] = true, [10] = true }
local MAKEUP_COLOR_OVERLAYS = { [4] = true, [5] = true, [8] = true }

local function applyHeadBlend(ped, hb)
    if type(hb) ~= 'table' then return end
    SetPedHeadBlendData(ped,
        tonumber(hb.shapeFirst) or 0, tonumber(hb.shapeSecond) or 0, 0,
        tonumber(hb.skinFirst) or 0, tonumber(hb.skinSecond) or 0, 0,
        (tonumber(hb.shapeMix) or 0.5) + 0.0, (tonumber(hb.skinMix) or 0.5) + 0.0, 0.0,
        false)
end

local function applyFeatures(ped, features)
    if type(features) ~= 'table' then return end
    for index, value in pairs(features) do
        SetPedFaceFeature(ped, tonumber(index), (tonumber(value) or 0.0) + 0.0)
    end
end

local function applyOverlay(ped, idx, overlay)
    if type(overlay) ~= 'table' then return end
    local style = tonumber(overlay.style) or 0
    if style == 0 or style == 255 then
        SetPedHeadOverlay(ped, idx, 255, 0.0)
        return
    end
    SetPedHeadOverlay(ped, idx, style - 1, (tonumber(overlay.opacity) or 1.0) + 0.0)
    if HAIR_COLOR_OVERLAYS[idx] then
        SetPedHeadOverlayColor(ped, idx, 1, tonumber(overlay.color) or 0, tonumber(overlay.secondColor) or 0)
    elseif MAKEUP_COLOR_OVERLAYS[idx] then
        SetPedHeadOverlayColor(ped, idx, 2, tonumber(overlay.color) or 0, tonumber(overlay.secondColor) or 0)
    end
end

local function applyHair(ped, hair)
    if type(hair) ~= 'table' then return end
    if hair.style ~= nil then
        SetPedComponentVariation(ped, 2, tonumber(hair.style) or 0, tonumber(hair.texture) or 0, 0)
    end
    SetPedHairColor(ped, tonumber(hair.color) or 0, tonumber(hair.highlight) or 0)
end

---Apply a canonical (or legacy default-shape) appearance to any ped. Safe to call
---on preview peds and the local player. Returns true.
---@param ped number
---@param data table
---@return boolean
function A.applyToPed(ped, data)
    if not ped or ped == 0 or type(data) ~= 'table' then return false end
    local canonical = A.normalize(data)
    local hasHair = type(canonical.hair) == 'table'

    if canonical.headBlend then applyHeadBlend(ped, canonical.headBlend) end
    if canonical.features then applyFeatures(ped, canonical.features) end
    if canonical.overlays then
        for index, overlay in pairs(canonical.overlays) do
            applyOverlay(ped, tonumber(index), overlay)
        end
    end
    if canonical.eyeColor ~= nil then SetPedEyeColor(ped, tonumber(canonical.eyeColor) or 0) end
    if hasHair then applyHair(ped, canonical.hair) end

    for id, c in pairs(canonical.components) do
        local cid = tonumber(id)
        -- Hair (component 2) is applied from the hair block when present, so it's
        -- skipped here to keep its texture/colour.
        if not (cid == 2 and hasHair) then
            SetPedComponentVariation(ped, cid, tonumber(c.drawable) or 0, tonumber(c.texture) or 0, 0)
        end
    end

    for id, p in pairs(canonical.props) do
        local pid = tonumber(id)
        local drawable = tonumber(p.drawable)
        if drawable == nil then drawable = -1 end
        if drawable == -1 then
            ClearPedProp(ped, pid)
        else
            SetPedPropIndex(ped, pid, drawable, tonumber(p.texture) or 0, true)
        end
    end

    if type(canonical.tattoos) == 'table' then
        ClearPedDecorations(ped)
        for _, t in ipairs(canonical.tattoos) do
            if t.collection and t.name then
                AddPedDecorationFromHashes(ped, joaat(t.collection), joaat(t.name))
            end
        end
    end

    return true
end

RegisterNetEvent('o-link:clothing:applyAppearance', function(data)
    A.applyToPed(PlayerPedId(), data)
end)

-- Tattoo-only resync fired by SaveTattoos. Distinct from applyAppearance so a
-- tattoo save never clobbers a separate clothing edit.
RegisterNetEvent('o-link:client:clothing:applyTattoos', function(tattoos)
    olink.clothing.ApplyTattoos(PlayerPedId(), tattoos)
end)
