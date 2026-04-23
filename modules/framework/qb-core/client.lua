if not olink._guardImpl('Framework', 'qb-core', 'qb-core') then return end
if not olink._hasOverride('Framework') and GetResourceState('qbx_core') == 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

olink._register('framework', {
    GetResourceName = function()
        return 'qb-core'
    end,

    ---@return string
    GetName = function()
        return 'qb-core'
    end,

    ---@return boolean
    GetIsPlayerLoaded = function()
        local playerData = QBCore.Functions.GetPlayerData()
        return playerData ~= nil and playerData.citizenid ~= nil
    end,

    ShowHelpText = function(message, position)
        return exports['qb-core']:DrawText(message, position)
    end,

    HideHelpText = function()
        return exports['qb-core']:HideText()
    end,
})
