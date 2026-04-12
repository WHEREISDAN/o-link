if GetResourceState('bcs-housing') ~= 'started' then return end

olink._register('housing', {
    ---@return string
    GetResourceName = function()
        return 'bcs-housing'
    end,
})
