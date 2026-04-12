if GetResourceState('linden_outlawalert') == 'missing' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'linden_outlawalert'
    end,
})
