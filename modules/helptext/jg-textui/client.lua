if GetResourceState('jg-textui') == 'missing' then return end

olink._register('helptext', {
    ---@param message string
    ---@param position string|nil
    Show = function(message, position)
        exports['jg-textui']:DrawText(message)
    end,

    Hide = function()
        exports['jg-textui']:HideText()
    end,
})
