if not olink._guardImpl('Dispatch', 'origen_police', 'origen_police') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'origen_police'
    end,
})
