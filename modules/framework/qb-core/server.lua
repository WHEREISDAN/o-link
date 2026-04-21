if not olink._guardImpl('Framework', 'qb-core', 'qb-core') then return end
if not olink._hasOverride('Framework') and GetResourceState('qbx_core') == 'started' then return end

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

    ---@param src number
    ---@return boolean
    Logout = function(src)
        QBCore.Functions.Logout(src)
        return true
    end,

    ---@description Returns the entire inventory of the player as a table.
    ---@param src number
    ---@return table[] { name, count, metadata, slot }
    GetPlayerInventory = function(src)
        local player = QBCore.Functions.GetPlayer(src)
        if not player then return {} end
        local items = player.PlayerData and player.PlayerData.items
        if not items then return {} end
        local result = {}
        for _, v in pairs(items) do
            if v and v.name then
                result[#result + 1] = {
                    name     = v.name,
                    count    = v.amount or v.count,
                    metadata = v.info or v.metadata or {},
                    slot     = v.slot,
                }
            end
        end
        return result
    end,
})
