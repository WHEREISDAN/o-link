if GetResourceState('wasabi_mdt') == 'missing' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'wasabi_mdt'
    end,
})
