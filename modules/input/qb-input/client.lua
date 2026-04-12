if GetResourceState('qb-input') == 'missing' then return end

-- Type conversion helpers
local function QBTypeToOxType(_type)
    if _type == 'text' then return 'input'
    elseif _type == 'password' then return 'input'
    elseif _type == 'number' then return 'number'
    elseif _type == 'radio' then return 'checkbox'
    elseif _type == 'checkbox' then return 'checkbox'
    elseif _type == 'select' then return 'select'
    end
end

local function OxTypeToQBType(_type)
    if _type == 'input' then return 'text'
    elseif _type == 'number' then return 'number'
    elseif _type == 'checkbox' then return 'checkbox'
    elseif _type == 'select' then return 'select'
    elseif _type == 'multi-select' then return 'select'
    elseif _type == 'slider' then return 'number'
    elseif _type == 'color' then return 'text'
    elseif _type == 'date' then return 'date'
    elseif _type == 'date-range' then return 'date'
    elseif _type == 'time' then return 'time'
    elseif _type == 'textarea' then return 'text'
    end
end

local function OxToQBInput(data)
    local returnData = {}
    for i, v in pairs(data) do
        local input = {
            text = v.label,
            name = i,
            type = OxTypeToQBType(v.type),
            isRequired = v.required,
            default = v.default or '',
        }
        if v.type == 'select' then
            input.text = ''
            input.options = {}
            for k, j in pairs(v.options) do
                table.insert(input.options, { value = j.value, text = j.label })
            end
        elseif v.type == 'checkbox' then
            input.text = ''
            input.options = {}
            if v.options then
                for k, j in pairs(v.options) do
                    table.insert(input.options, { value = #returnData + #input.options + 1, text = j.label, checked = j.checked })
                end
            else
                table.insert(input.options, { value = #returnData + 1, text = v.label, checked = v.checked })
            end
        end
        table.insert(returnData, input)
    end
    return returnData
end

olink._register('input', {
    ---@return string
    GetResourceName = function()
        return 'qb-input'
    end,

    ---@param title string
    ---@param data table
    ---@param isQBFormat boolean|nil
    ---@param submitText string|nil
    ---@return table|nil
    Open = function(title, data, isQBFormat, submitText)
        local input = data.inputs
        if not isQBFormat then
            input = OxToQBInput(data)
        end
        local returnData = exports['qb-input']:ShowInput({
            header = title,
            submitText = submitText or 'Submit',
            inputs = input,
        })
        if not returnData then return end
        if returnData[1] then return returnData end
        -- Convert to standard format (ox)
        local convertedData = {}
        if isQBFormat then
            for i, v in pairs(input) do
                for k, j in pairs(returnData) do
                    if k == v.name then
                        convertedData[v.name] = j
                    end
                end
            end
            return convertedData
        end
        for i, v in pairs(returnData) do
            v = tostring(v) == 'true' and true or (tostring(v) == 'false' and false or v)
            local index = i and tonumber(i)
            if not index then
                table.insert(convertedData, v)
            else
                convertedData[index] = v
            end
        end
        return convertedData
    end,
})
