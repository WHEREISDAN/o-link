if GetResourceState('ps-dispatch') == 'missing' then return end
if GetResourceState('lb-tablet') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'ps-dispatch'
    end,
})
