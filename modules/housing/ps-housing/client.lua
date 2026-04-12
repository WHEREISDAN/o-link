if GetResourceState('ps-housing') ~= 'started' then return end

olink._register('housing', {
    ---@return string
    GetResourceName = function()
        return 'ps-housing'
    end,
})
