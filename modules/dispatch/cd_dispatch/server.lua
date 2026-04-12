if GetResourceState('cd_dispatch') == 'missing' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'cd_dispatch'
    end,
})
