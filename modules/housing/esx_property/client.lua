if GetResourceState('esx_property') ~= 'started' then return end

olink._register('housing', {
    ---@return string
    GetResourceName = function()
        return 'esx_property'
    end,
})
