if GetResourceState('lab-HintUI') ~= 'started' then return end

olink._register('helptext', {
    ---@param message string
    ---@param position string|nil
    Show = function(message, position)
        exports['lab-HintUI']:Show(message, 'Hint Text')
    end,

    Hide = function()
        exports['lab-HintUI']:Hide()
    end,
})
