if GetResourceState('qs-dispatch') == 'missing' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'qs-dispatch'
    end,
})
