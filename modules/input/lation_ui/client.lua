if GetResourceState('lation_ui') == 'missing' then return end
if GetResourceState('qb-input') == 'started' then return end

-- Type conversion helpers
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

local function QBToOxInput(data)
    local returnData = {}
    for i, v in pairs(data) do
        local input = {
            label = v.text,
            name = i,
            type = (function()
                if v.type == 'text' then return 'input'
                elseif v.type == 'password' then return 'input'
                elseif v.type == 'number' then return 'number'
                elseif v.type == 'radio' then return 'checkbox'
                elseif v.type == 'checkbox' then return 'checkbox'
                elseif v.type == 'select' then return 'select'
                end
            end)(),
            required = v.isRequired,
            default = v.placeholder,
        }
        if v.type == 'select' then
            input.options = {}
            for k, j in pairs(v.options) do
                table.insert(input.options, { value = j.value, label = j.text })
            end
        elseif v.type == 'checkbox' then
            for k, j in pairs(v.options) do
                table.insert(returnData, { value = j.value, label = j.text })
            end
        end
        table.insert(returnData, input)
    end
    return returnData
end

olink._register('input', {
    ---@return string
    GetResourceName = function()
        return 'lation_ui'
    end,

    ---@param title string
    ---@param data table
    ---@param isQBFormat boolean|nil
    ---@param submitText string|nil
    ---@return table|nil
    Open = function(title, data, isQBFormat, submitText)
        local inputs = data.inputs
        if isQBFormat then
            return exports.lation_ui:input({ title = title, inputs = QBToOxInput(inputs) })
        else
            return exports.lation_ui:input({ title = title, options = data })
        end
    end,
})
