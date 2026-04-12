if GetResourceState('qs-dispatch') ~= 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'qs-dispatch'
    end,
})
