if GetResourceState('oxide-identity') ~= 'started' then return end

-- oxide-identity uses numeric component IDs {[0]={drawable,texture},...} for both components and props
-- JSON-decoded keys may be strings, so we normalize them to numbers

local function normalizeKeys(tbl)
    local result = {}
    for k, v in pairs(tbl) do
        result[tonumber(k) or k] = v
    end
    return result
end

local function convertComponentsToDefault(nativeComponents)
    local result = {}
    for k, v in pairs(nativeComponents or {}) do
        local id = tonumber(k)
        if id and v.drawable then
            result[id] = { component_id = id, drawable = v.drawable, texture = v.texture }
        end
    end
    return result
end

local function convertComponentsFromDefault(defaultComponents)
    local result = {}
    for _, v in pairs(defaultComponents or {}) do
        if v.component_id then
            result[v.component_id] = { drawable = v.drawable, texture = v.texture }
        end
    end
    return result
end

local function convertPropsToDefault(nativeProps)
    local result = {}
    for k, v in pairs(nativeProps or {}) do
        local id = tonumber(k)
        if id and v.drawable then
            result[#result + 1] = { prop_id = id, drawable = v.drawable, texture = v.texture }
        end
    end
    table.sort(result, function(a, b) return a.prop_id < b.prop_id end)
    return result
end

local function convertPropsFromDefault(defaultProps)
    local result = {}
    for _, v in pairs(defaultProps or {}) do
        if v.prop_id then
            result[v.prop_id] = { drawable = v.drawable, texture = v.texture }
        end
    end
    return result
end

---@param nativeData table {components, props}
---@return table {components, props}
function OxideIdentityConvertToDefault(nativeData)
    return {
        components = convertComponentsToDefault(normalizeKeys(nativeData.components or {})),
        props = convertPropsToDefault(normalizeKeys(nativeData.props or {})),
    }
end

---@param defaultData table {components, props}
---@return table {components, props}
function OxideIdentityConvertFromDefault(defaultData)
    return {
        components = convertComponentsFromDefault(defaultData.components),
        props = convertPropsFromDefault(defaultData.props),
    }
end
