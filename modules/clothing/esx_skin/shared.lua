if GetResourceState('esx_skin') ~= 'started' then return end
if GetResourceState('rcore_clothing') == 'started' then return end
if GetResourceState('17mov_CharacterSystem') == 'started' then return end

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
