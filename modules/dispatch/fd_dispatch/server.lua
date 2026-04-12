if GetResourceState('fd_dispatch') ~= 'started' then return end
if GetResourceState('lb-tablet') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'fd_dispatch'
    end,
})
