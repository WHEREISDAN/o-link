if GetResourceState('qb-core') == 'missing' then return end
if GetResourceState('qbx_core') == 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

olink._register('character', {
    ---@return string|nil
    GetIdentifier = function()
        local playerData = QBCore.Functions.GetPlayerData()
        if not playerData then return nil end
        return playerData.citizenid
    end,

    ---@return string|nil firstName, string|nil lastName
    GetName = function()
        local playerData = QBCore.Functions.GetPlayerData()
        if not playerData or not playerData.charinfo then return nil, nil end
        return playerData.charinfo.firstname, playerData.charinfo.lastname
    end,

    ---@param key string
    ---@return any|nil
    GetMetadata = function(key)
        local playerData = QBCore.Functions.GetPlayerData()
        if not playerData or not playerData.metadata then return nil end
        return playerData.metadata[key]
    end,
})
