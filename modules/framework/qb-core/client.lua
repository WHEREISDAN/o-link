if GetResourceState('qb-core') ~= 'started' then return end
if GetResourceState('qbx_core') == 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

olink._register('framework', {
    ---@return string
    GetName = function()
        return 'qb-core'
    end,

    ---@return boolean
    GetIsPlayerLoaded = function()
        local playerData = QBCore.Functions.GetPlayerData()
        return playerData ~= nil and playerData.citizenid ~= nil
    end,
})
