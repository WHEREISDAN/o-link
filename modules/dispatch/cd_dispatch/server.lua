if GetResourceState('cd_dispatch') ~= 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'cd_dispatch'
    end,
})
