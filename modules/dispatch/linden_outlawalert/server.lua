if GetResourceState('linden_outlawalert') ~= 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'linden_outlawalert'
    end,
})
