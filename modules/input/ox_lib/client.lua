if not olink._guardImpl('Input', 'ox_lib', 'ox_lib') then return end
if not olink._hasOverride('Input') and GetResourceState('qb-input') == 'started' then return end
if not olink._hasOverride('Input') and GetResourceState('lation_ui') == 'started' then return end

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
        return 'ox_lib'
    end,

    ---@param title string
    ---@param data table
    ---@param isQBFormat boolean|nil
    ---@param submitText string|nil
    ---@return table|nil
    Open = function(title, data, isQBFormat, submitText)
        local inputs = data.inputs
        if isQBFormat then
            local convertedData = {}
            local returnData = lib.inputDialog(title, QBToOxInput(inputs))
            for i, v in pairs(inputs) do
                for k, j in pairs(returnData or {}) do
                    if k == v.name then
                        convertedData[v.name] = j
                    end
                end
            end
            return convertedData
        else
            return lib.inputDialog(title, data)
        end
    end,
})
