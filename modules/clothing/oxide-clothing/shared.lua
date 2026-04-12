if GetResourceState('oxide-clothing') ~= 'started' then return end

-- oxide-clothing uses numeric component IDs {[0]={drawable,texture},...} for both components and props

local function convertComponentsToDefault(oxideComponents)
    local result = {}
    for k, v in pairs(oxideComponents or {}) do
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

local function convertPropsToDefault(oxideProps)
    local result = {}
    for k, v in pairs(oxideProps or {}) do
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
function OxideClothingConvertToDefault(nativeData)
    return {
        components = convertComponentsToDefault(nativeData.components),
        props = convertPropsToDefault(nativeData.props),
    }
end

---@param defaultData table {components, props}
---@return table {components, props}
function OxideClothingConvertFromDefault(defaultData)
    return {
        components = convertComponentsFromDefault(defaultData.components),
        props = convertPropsFromDefault(defaultData.props),
    }
end
