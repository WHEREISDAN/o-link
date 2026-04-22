if not olink._guardImpl('Dispatch', 'fd_dispatch', 'fd_dispatch') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end
if not olink._hasOverride('Dispatch') and GetResourceState('lb-tablet') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'fd_dispatch'
    end,
})
