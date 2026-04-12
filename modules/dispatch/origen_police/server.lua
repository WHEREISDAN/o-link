if GetResourceState('origen_police') ~= 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'origen_police'
    end,
})
