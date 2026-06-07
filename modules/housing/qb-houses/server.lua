if not olink._guardImpl('Housing', 'qb-houses', 'qb-houses') then return end

RegisterNetEvent('qb-houses:server:SetInsideMeta', function(insideId, bool)
    local src = source
    insideId = bool and insideId or nil
    TriggerEvent('o-link:server:OnPlayerInside', src, insideId)
end)

olink._register('housing', {
    ---@return string
    GetResourceName = function()
        return 'qb-houses'
    end,
})
