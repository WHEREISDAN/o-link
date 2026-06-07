if not olink._guardImpl('Housing', 'qb-houses', 'qb-houses') then return end

olink._register('housing', {
    ---@return string
    GetResourceName = function()
        return 'qb-houses'
    end,
})
