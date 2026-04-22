if not olink._guardImpl('Dispatch', 'qs_dispatch', 'qs-dispatch') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'qs-dispatch'
    end,
})
