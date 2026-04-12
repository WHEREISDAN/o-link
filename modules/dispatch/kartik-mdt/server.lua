if GetResourceState('kartik-mdt') ~= 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'kartik-mdt'
    end,
})
