-- Default input fallback.
-- Provides QB<->Ox schema conversion helpers mirrored from community_bridge.
-- Open() is a stub: returns nil when no input UI is available.

if not olink._guardImpl('Input', '_default', false) then return end
if not olink._hasOverride('Input') and GetResourceState('lation_ui') == 'started' then return end
if not olink._hasOverride('Input') and GetResourceState('ox_lib') == 'started' then return end
if not olink._hasOverride('Input') and GetResourceState('qb-input') == 'started' then return end

local function QBTypeToOxType(_type)
    if _type == 'text' or _type == 'password' then return 'input'
    elseif _type == 'number' then return 'number'
    elseif _type == 'radio' or _type == 'checkbox' then return 'checkbox'
    elseif _type == 'select' then return 'select'
    end
end

local function QBToOxInput(data)
    local returnData = {}
    for i, v in pairs(data) do
        local input = {
            label    = v.text,
            name     = i,
            type     = QBTypeToOxType(v.type),
            required = v.isRequired,
            default  = v.placeholder,
        }
        if v.type == 'select' then
            input.options = {}
            for _, o in pairs(v.options or {}) do
                table.insert(input.options, { value = o.value, label = o.text })
            end
        elseif v.type == 'checkbox' then
            for _, o in pairs(v.options or {}) do
                table.insert(returnData, { value = o.value, label = o.text })
            end
        end
        table.insert(returnData, input)
    end
    return returnData
end

local function OxTypeToQBType(_type)
    if _type == 'input' or _type == 'textarea' or _type == 'color' then return 'text'
    elseif _type == 'number' or _type == 'slider' then return 'number'
    elseif _type == 'checkbox' then return 'checkbox'
    elseif _type == 'select' or _type == 'multi-select' then return 'select'
    elseif _type == 'date' or _type == 'date-range' then return 'date'
    elseif _type == 'time' then return 'time'
    end
end

local function OxToQBInput(data)
    local returnData = {}
    for i, v in pairs(data) do
        local input = {
            text       = v.label,
            name       = i,
            type       = OxTypeToQBType(v.type),
            isRequired = v.required,
            default    = v.default or '',
        }
        if v.type == 'select' then
            input.text = ''
            input.options = {}
            for _, o in pairs(v.options or {}) do
                table.insert(input.options, { value = o.value, text = o.label })
            end
        elseif v.type == 'checkbox' then
            input.text = ''
            input.options = {}
            if v.options then
                for _, o in pairs(v.options) do
                    table.insert(input.options, { value = #returnData + #input.options + 1, text = o.label, checked = o.checked })
                end
            else
                table.insert(input.options, { value = #returnData + 1, text = v.label, checked = v.checked })
            end
        end
        table.insert(returnData, input)
    end
    return returnData
end

olink._registerDefault('input', {
    GetResourceName = function() return '_default' end,
    Open = function() return nil end,
    QBTypeToOxType = QBTypeToOxType,
    QBToOxInput    = QBToOxInput,
    OxTypeToQBType = OxTypeToQBType,
    OxToQBInput    = OxToQBInput,
})
