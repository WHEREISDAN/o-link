if not olink._guardImpl('Dispatch', 'lb-tablet', 'lb-tablet') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'lb-tablet'
    end,
})

RegisterNetEvent('o-link:dispatch:lb-tablet:sendAlert', function(data)
    exports['lb-tablet']:AddDispatch(data)
end)
