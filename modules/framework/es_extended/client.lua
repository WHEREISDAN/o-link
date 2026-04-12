if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

olink._register('framework', {
    ---@return string
    GetName = function()
        return 'es_extended'
    end,

    ---@return boolean
    GetIsPlayerLoaded = function()
        return ESX.IsPlayerLoaded()
    end,
})
