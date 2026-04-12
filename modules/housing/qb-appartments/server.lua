if GetResourceState('qb-appartments') ~= 'started' then return end

RegisterNetEvent('qb-apartments:server:SetInsideMeta', function(house, insideId, bool, isVisiting)
    local src = source
    insideId = bool and house .. '-' .. insideId or nil
    TriggerEvent('o-link:server:OnPlayerInside', src, insideId)
end)

olink._register('housing', {
    ---@return string
    GetResourceName = function()
        return 'qb-appartments'
    end,
})
