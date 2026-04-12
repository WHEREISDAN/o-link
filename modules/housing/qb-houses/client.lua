if GetResourceState('qb-houses') == 'missing' then return end

olink._register('housing', {
    ---@return string
    GetResourceName = function()
        return 'qb-houses'
    end,
})
