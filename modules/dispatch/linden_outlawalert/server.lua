if not olink._guardImpl('Dispatch', 'linden_outlawalert', 'linden_outlawalert') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'linden_outlawalert'
    end,
})
