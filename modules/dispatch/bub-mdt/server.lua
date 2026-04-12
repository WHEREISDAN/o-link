if GetResourceState('bub-mdt') == 'missing' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'bub-mdt'
    end,
})
