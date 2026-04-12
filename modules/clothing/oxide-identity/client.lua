if GetResourceState('oxide-identity') ~= 'started' then return end

olink._register('clothing', {
    ---@return string
    GetResourceName = function()
        return 'oxide-identity'
    end,

    OpenMenu = function()
        exports['oxide-identity']:OpenClothing()
    end,
})

RegisterNetEvent('o-link:client:clothing:openMenu', function()
    exports['oxide-identity']:OpenClothing()
end)

RegisterNetEvent('o-link:client:clothing:setAppearance', function(data)
    TriggerEvent('o-link:clothing:applyAppearance', data)
end)
