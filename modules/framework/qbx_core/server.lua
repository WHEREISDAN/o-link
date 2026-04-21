if not olink._guardImpl('Framework', 'qbx_core', 'qbx_core') then return end

local QBox = exports.qbx_core

olink._register('framework', {
    ---@return string
    GetName = function()
        return 'qbx_core'
    end,

    ---@param src number
    ---@return boolean
    GetIsPlayerLoaded = function(src)
        local player = QBox:GetPlayer(src)
        return player ~= nil
    end,

    ---@return number[]
    GetPlayers = function()
        local players = QBox:GetQBPlayers()
        local list = {}
        for src in pairs(players) do
            list[#list + 1] = src
        end
        return list
    end,

    ---@return table[] { name, label, grades }
    GetJobs = function()
        local jobs = {}
        local qbJobs = exports.qbx_core:GetJobs()
        for k, v in pairs(qbJobs or {}) do
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
        QBox:CreateUseableItem(itemName, function(src, item)
            local itemData = item or {}
            itemData.metadata = itemData.metadata or itemData.info or {}
            itemData.slot = itemData.id or itemData.slot
            cb(src, itemData)
        end)
    end,

    ---@param src number
    ---@return boolean
    Logout = function(src)
        exports.qbx_core:Logout(src)
        return true
    end,

    ---@description Returns the entire inventory of the player as a table.
    ---@param src number
    ---@return table[] { name, count, metadata, slot }
    GetPlayerInventory = function(src)
        local player = QBox:GetPlayer(src)
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
