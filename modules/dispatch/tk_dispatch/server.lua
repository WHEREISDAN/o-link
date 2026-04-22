if not olink._guardImpl('Dispatch', 'tk_dispatch', 'tk_dispatch') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'tk_dispatch'
    end,
})
