if GetResourceState('ps-housing') == 'missing' then return end

olink._register('housing', {
    ---@return string
    GetResourceName = function()
        return 'ps-housing'
    end,
})
