if GetResourceState('tk_dispatch') ~= 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'tk_dispatch'
    end,
})
