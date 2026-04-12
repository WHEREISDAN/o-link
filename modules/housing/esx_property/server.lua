if GetResourceState('esx_property') ~= 'started' then return end

RegisterNetEvent('esx_property:enter', function(insideId)
    local src = source
    TriggerEvent('o-link:server:OnPlayerInside', src, insideId)
end)

RegisterNetEvent('esx_property:leave', function(insideId)
    local src = source
    TriggerEvent('o-link:server:OnPlayerInside', src, insideId)
end)

olink._register('housing', {
    ---@return string
    GetResourceName = function()
        return 'esx_property'
    end,
})
