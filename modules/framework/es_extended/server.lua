if GetResourceState('es_extended') == 'missing' then return end

local ESX = exports['es_extended']:getSharedObject()

olink._register('framework', {
    ---@return string
    GetName = function()
        return 'es_extended'
    end,

    ---@param src number
    ---@return boolean
    GetIsPlayerLoaded = function(src)
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer ~= nil
    end,

    ---@return number[]
    GetPlayers = function()
        local players = ESX.GetExtendedPlayers()
        local list = {}
        for _, xPlayer in pairs(players) do
            list[#list + 1] = xPlayer.source
        end
        return list
    end,

    ---@return table[] { name, label, grades }
    GetJobs = function()
        local jobs = {}
        local esxJobs = ESX.GetJobs()
        for k, v in pairs(esxJobs or {}) do
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
        ESX.RegisterUsableItem(itemName, function(src, item, itemData)
            itemData = itemData or item or {}
            itemData.metadata = itemData.metadata or itemData.info or {}
            itemData.slot = itemData.id or itemData.slot
            cb(src, itemData)
        end)
    end,
})
