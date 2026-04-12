if GetResourceState('kartik-mdt') == 'missing' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'kartik-mdt'
    end,
})
