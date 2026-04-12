if GetResourceState('qb-clothing') ~= 'started' then return end
if GetResourceState('oxide-clothing') == 'started' then return end
if GetResourceState('rcore_clothing') == 'started' then return end
if GetResourceState('17mov_CharacterSystem') == 'started' then return end

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
