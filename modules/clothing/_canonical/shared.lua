-- Canonical appearance object — the single o-link `clothing` dialect.
--
-- Shape (mirrors oxide-multichar/client/modules/appearance.lua):
--   {
--     model      = 'mp_m_freemode_01',
--     headBlend  = { shapeFirst, shapeSecond, shapeMix, skinFirst, skinSecond, skinMix },
--     features   = { [0..19] = number },
--     overlays   = { [0..12] = { style, opacity, color, secondColor } },  -- style 0 = none (1-based)
--     hair       = { style, texture, color, highlight },
--     eyeColor   = number,
--     components = { [id] = { drawable, texture } },
--     props      = { [id] = { drawable, texture } },                      -- drawable -1 = none
--     tattoos    = { { collection, name, zone, label } },
--   }
--
-- Loaded guard-free as a shared script so these helpers exist for every clothing
-- adapter, both server (DB converters) and client (native applier). They replace
-- the old split between the "default shape" (components/props arrays) and the
-- "creator object": adapters now translate one canonical object, and the legacy
-- {components, props} payload is normalized into it transparently.

olink._appearance = olink._appearance or {}
local A = olink._appearance

-- Rich-field keys that mark an appearance as more than bare clothing.
local RICH_KEYS = { 'hair', 'overlays', 'headBlend', 'features', 'eyeColor', 'tattoos' }

---Coerce a components payload (array `[{component_id,drawable,texture}]` OR map
---`{[id]={drawable,texture}}`) into a map keyed by numeric component id.
---@param components table|nil
---@return table<number, {drawable:number, texture:number}>
function A.componentsToMap(components)
    local out = {}
    if type(components) ~= 'table' then return out end
    for k, v in pairs(components) do
        if type(v) == 'table' then
            local id = tonumber(v.component_id) or tonumber(k)
            if id then
                out[id] = { drawable = tonumber(v.drawable) or 0, texture = tonumber(v.texture) or 0 }
            end
        end
    end
    return out
end

---Coerce a props payload (array `[{prop_id,drawable,texture}]` OR map) into a map
---keyed by numeric prop id. Missing drawables default to -1 (no prop).
---@param props table|nil
---@return table<number, {drawable:number, texture:number}>
function A.propsToMap(props)
    local out = {}
    if type(props) ~= 'table' then return out end
    for k, v in pairs(props) do
        if type(v) == 'table' then
            local id = tonumber(v.prop_id) or tonumber(k)
            if id then
                local drawable = tonumber(v.drawable)
                if drawable == nil then drawable = -1 end
                out[id] = { drawable = drawable, texture = tonumber(v.texture) or 0 }
            end
        end
    end
    return out
end

---Convert a components map into the legacy array shape consumers expect.
---@param map table<number, {drawable:number, texture:number}>|nil
---@return table[]
function A.componentsToArray(map)
    local out = {}
    if type(map) ~= 'table' then return out end
    for id, v in pairs(map) do
        local cid = tonumber(v.component_id) or tonumber(id)
        if cid and type(v) == 'table' then
            out[#out + 1] = { component_id = cid, drawable = tonumber(v.drawable) or 0, texture = tonumber(v.texture) or 0 }
        end
    end
    table.sort(out, function(a, b) return a.component_id < b.component_id end)
    return out
end

---Convert a props map into the legacy array shape consumers expect.
---@param map table<number, {drawable:number, texture:number}>|nil
---@return table[]
function A.propsToArray(map)
    local out = {}
    if type(map) ~= 'table' then return out end
    for id, v in pairs(map) do
        local pid = tonumber(v.prop_id) or tonumber(id)
        if pid and type(v) == 'table' then
            local drawable = tonumber(v.drawable)
            if drawable == nil then drawable = -1 end
            out[#out + 1] = { prop_id = pid, drawable = drawable, texture = tonumber(v.texture) or 0 }
        end
    end
    table.sort(out, function(a, b) return a.prop_id < b.prop_id end)
    return out
end

---Rebuild an index-keyed table with integer keys (a JSON round-trip turns numeric
---keys into strings). Returns a fresh table; non-tables pass through.
---@param t table|nil
---@return table|nil
function A.toIntKeyed(t)
    if type(t) ~= 'table' then return t end
    local out = {}
    for k, v in pairs(t) do
        out[tonumber(k) or k] = v
    end
    return out
end

---Does this payload carry any rich appearance fields (vs. bare clothing)?
---@param data table|nil
---@return boolean
function A.isRich(data)
    if type(data) ~= 'table' then return false end
    for _, key in ipairs(RICH_KEYS) do
        if data[key] ~= nil then return true end
    end
    return false
end

---Normalize any accepted input (legacy {components, props} arrays/maps, or a full
---canonical object) into a canonical table with components/props as id-keyed maps.
---Rich fields are passed through untouched. Always returns a fresh table; never
---mutates the input.
---@param data table|nil
---@return table canonical
function A.normalize(data)
    data = type(data) == 'table' and data or {}
    local out = {
        components = A.componentsToMap(data.components),
        props = A.propsToMap(data.props),
    }
    if data.model ~= nil then out.model = data.model end
    if data.headBlend ~= nil then out.headBlend = data.headBlend end
    -- overlays (0-12) and features (0-19) are index-keyed. A JSON round-trip (e.g.
    -- backends that persist `face` as JSON) turns numeric keys into strings, so
    -- coerce them back to integer keys — a single key type lets a partial merge
    -- overwrite a slot instead of leaving both an integer and a string entry.
    if data.features ~= nil then out.features = A.toIntKeyed(data.features) end
    if data.overlays ~= nil then out.overlays = A.toIntKeyed(data.overlays) end
    if data.eyeColor ~= nil then out.eyeColor = data.eyeColor end
    if data.hair ~= nil then out.hair = data.hair end
    if data.tattoos ~= nil then out.tattoos = data.tattoos end
    return out
end

---Merge a (possibly partial) canonical `patch` over a `base` canonical object,
---returning a new table. components/props/overlays merge by id; hair/headBlend
---merge field-wise; scalars and tattoos replace when present in the patch.
---@param base table|nil
---@param patch table|nil
---@return table
function A.merge(base, patch)
    base = A.normalize(base)
    patch = A.normalize(patch)

    for id, v in pairs(patch.components) do base.components[id] = v end
    for id, v in pairs(patch.props) do base.props[id] = v end

    if patch.overlays then
        base.overlays = base.overlays or {}
        for id, v in pairs(patch.overlays) do base.overlays[tonumber(id) or id] = v end
    end
    if patch.hair then
        base.hair = base.hair or {}
        for k, v in pairs(patch.hair) do base.hair[k] = v end
    end
    if patch.headBlend then
        base.headBlend = base.headBlend or {}
        for k, v in pairs(patch.headBlend) do base.headBlend[k] = v end
    end
    if patch.features then
        base.features = base.features or {}
        for k, v in pairs(patch.features) do base.features[tonumber(k) or k] = v end
    end
    if patch.eyeColor ~= nil then base.eyeColor = patch.eyeColor end
    if patch.model ~= nil then base.model = patch.model end
    if patch.tattoos ~= nil then base.tattoos = patch.tattoos end

    return base
end
