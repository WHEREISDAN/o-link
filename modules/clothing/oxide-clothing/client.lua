if GetResourceState('oxide-clothing') == 'missing' then return end

olink._register('clothing', {
    ---@return string
    GetResourceName = function()
        return 'oxide-clothing'
    end,

    OpenMenu = function()
        TriggerEvent('qb-clothing:client:openMenu')
    end,
})

RegisterNetEvent('o-link:client:clothing:setAppearance', function(data)
    TriggerEvent('o-link:clothing:applyAppearance', data)
end)
