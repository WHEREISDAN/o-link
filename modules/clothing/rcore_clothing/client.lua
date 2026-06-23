if not olink._guardImpl('Clothing', 'rcore_clothing', 'rcore_clothing') then return end
if not olink._hasOverride('Clothing') and GetResourceState('17mov_CharacterSystem') == 'started' then return end

olink._register('clothing', {
    ---@return string
    GetResourceName = function()
        return 'rcore_clothing'
    end,

    OpenMenu = function()
        TriggerEvent('qb-clothing:client:openMenu')
    end,
})

RegisterNetEvent('o-link:client:clothing:setAppearance', function(data)
    TriggerEvent('o-link:clothing:applyAppearance', data)
end)

-- Apply a canonical look to the player ped, then (when persisting) let rcore
-- snapshot the now-updated ped into its own correctly-encoded current outfit.
-- Applying first is synchronous, so saveCurrentSkin captures the new look.
RegisterNetEvent('o-link:rcore:applyPersist', function(data, persist)
    local ped = PlayerPedId()
    olink._appearance.applyToPed(ped, data)
    if persist then
        TriggerEvent('rcore_clothing:saveCurrentSkin')
    end
end)
