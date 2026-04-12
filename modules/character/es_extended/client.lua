if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

olink._register('character', {
    ---@return string|nil
    GetIdentifier = function()
        local playerData = ESX.GetPlayerData()
        if not playerData then return nil end
        return playerData.identifier
    end,

    ---@return string|nil firstName, string|nil lastName
    GetName = function()
        local playerData = ESX.GetPlayerData()
        if not playerData then return nil, nil end
        return playerData.firstName, playerData.lastName
    end,

    ---@param key string
    ---@return any|nil
    GetMetadata = function(key)
        local playerData = ESX.GetPlayerData()
        if not playerData or not playerData.metadata then return nil end
        return playerData.metadata[key]
    end,
})
