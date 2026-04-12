if GetResourceState('qb-houses') ~= 'started' then return end

olink._register('housing', {
    ---@return string
    GetResourceName = function()
        return 'qb-houses'
    end,
})
