if GetResourceState('bub-mdt') ~= 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'bub-mdt'
    end,
})
