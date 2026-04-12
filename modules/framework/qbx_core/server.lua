if GetResourceState('qbx_core') == 'missing' then return end

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
})
