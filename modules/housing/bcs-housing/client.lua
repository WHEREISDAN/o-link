if GetResourceState('bcs-housing') ~= 'started' then return end

RegisterNetEvent('Housing:client:EnterHome', function(insideId)
    TriggerServerEvent('o-link:server:OnPlayerInside', insideId)
end)

RegisterNetEvent("Housing:client:DeleteFurnitures", function()
    TriggerServerEvent('o-link:server:OnPlayerInside', false)
end)

olink._register('housing', {
    ---@return string
    GetResourceName = function()
        return 'bcs-housing'
    end,
})
