if GetResourceState('qb-appartments') ~= 'started' then return end

olink._register('housing', {
    ---@return string
    GetResourceName = function()
        return 'qb-appartments'
    end,
})
