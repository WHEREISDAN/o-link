if not olink._guardImpl('Dispatch', 'ps-dispatch', 'ps-dispatch') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end
if not olink._hasOverride('Dispatch') and GetResourceState('lb-tablet') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'ps-dispatch'
    end,
})
