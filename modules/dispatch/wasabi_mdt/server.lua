if not olink._guardImpl('Dispatch', 'wasabi_mdt', 'wasabi_mdt') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'wasabi_mdt'
    end,
})
