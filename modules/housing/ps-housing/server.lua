if GetResourceState('ps-housing') ~= 'started' then return end

RegisterNetEvent('ps-housing:server:enterProperty', function(insideId)
    local src = source
    TriggerEvent('o-link:server:OnPlayerInside', src, insideId)
end)

RegisterNetEvent('ps-housing:server:leaveProperty', function(insideId)
    local src = source
    TriggerEvent('o-link:server:OnPlayerInside', src, insideId)
end)

olink._register('housing', {
    ---@return string
    GetResourceName = function()
        return 'ps-housing'
    end,
})
