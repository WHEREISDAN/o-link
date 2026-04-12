if GetResourceState('lb-tablet') ~= 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'lb-tablet'
    end,
})

RegisterNetEvent('o-link:dispatch:lb-tablet:sendAlert', function(data)
    exports['lb-tablet']:AddDispatch(data)
end)
