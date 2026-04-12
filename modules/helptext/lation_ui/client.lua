if GetResourceState('lation_ui') == 'missing' then return end

olink._register('helptext', {
    ---@param message string
    ---@param position string|nil
    Show = function(message, position)
        exports.lation_ui:showText({ description = tostring(message), position = position or 'right-center' })
    end,

    Hide = function()
        exports.lation_ui:hideText()
    end,
})
