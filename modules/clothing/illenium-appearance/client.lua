if GetResourceState('illenium-appearance') == 'missing' then return end
if GetResourceState('rcore_clothing') == 'started' then return end
if GetResourceState('17mov_CharacterSystem') == 'started' then return end

olink._register('clothing', {
    ---@return string
    GetResourceName = function()
        return 'illenium-appearance'
    end,

    OpenMenu = function()
        TriggerEvent('qb-clothing:client:openMenu')
    end,
})

RegisterNetEvent('o-link:client:clothing:setAppearance', function(data)
    TriggerEvent('o-link:clothing:applyAppearance', data)
end)
