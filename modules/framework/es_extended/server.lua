if not olink._guardImpl('Framework', 'es_extended', 'es_extended') then return end

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

    ---@param src number
    ---@return boolean
    Logout = function(src)
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return false end
        TriggerEvent('esx:playerLogout', src)
        TriggerClientEvent('esx:onPlayerLogout', src)
        return true
    end,

    ---@description Returns the entire inventory of the player as a table.
    --- Note: base ESX does not support item metadata or slots. Inventories that
    --- provide slot/metadata storage (jpr, ps, qs, ox, etc.) should be read via
    --- their own adapter exports instead of this framework fallback.
    ---@param src number
    ---@return table[] { name, count, metadata, slot }
    GetPlayerInventory = function(src)
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return {} end
        local items = xPlayer.getInventory and xPlayer.getInventory() or {}
        local result = {}
        for _, v in pairs(items) do
            if v and v.name and (v.count or 0) > 0 then
                result[#result + 1] = {
                    name     = v.name,
                    count    = v.count,
                    metadata = {},
                    slot     = 0,
                }
            end
        end
        return result
    end,
})
