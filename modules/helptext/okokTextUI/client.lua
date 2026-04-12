if GetResourceState('okokTextUI') == 'missing' then return end

olink._register('helptext', {
    ---@param message string
    ---@param position string|nil
    Show = function(message, position)
        exports['okokTextUI']:Open(message, 'darkblue', position, false)
    end,

    Hide = function()
        exports['okokTextUI']:Close()
    end,
})
