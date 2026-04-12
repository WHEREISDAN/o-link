if GetResourceState('qb-core') ~= 'started' then return end
if GetResourceState('qbx_core') == 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

olink._register('framework', {
    ---@return string
    GetName = function()
        return 'qb-core'
    end,

    ---@param src number
    ---@return boolean
    GetIsPlayerLoaded = function(src)
        local player = QBCore.Functions.GetPlayer(src)
        return player ~= nil
    end,

    ---@return number[]
    GetPlayers = function()
        local players = QBCore.Functions.GetPlayers()
        local list = {}
        for _, src in pairs(players) do
            list[#list + 1] = src
        end
        return list
    end,

    ---@return table[] { name, label, grades }
    GetJobs = function()
        local jobs = {}
        for k, v in pairs(QBCore.Shared.Jobs) do
            jobs[#jobs + 1] = { name = k, label = v.label, grades = v.grades }
        end
        return jobs
    end,

    ---@param src number
    ---@return boolean
    IsAdmin = function(src)
        return IsPlayerAceAllowed(tostring(src), 'command')
    end,

    ---@param itemName string
    ---@param cb function(source, itemData)
    RegisterUsableItem = function(itemName, cb)
        QBCore.Functions.CreateUseableItem(itemName, function(src, item)
            local itemData = item or {}
            itemData.metadata = itemData.metadata or itemData.info or {}
            itemData.slot = itemData.id or itemData.slot
            cb(src, itemData)
        end)
    end,
})
