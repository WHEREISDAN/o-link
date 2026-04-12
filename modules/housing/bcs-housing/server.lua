if GetResourceState('bcs-housing') == 'missing' then return end

olink._register('housing', {
    ---@return string
    GetResourceName = function()
        return 'bcs-housing'
    end,
})
