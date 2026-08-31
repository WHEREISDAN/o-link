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
    -- Delegate to ESX so group-based admins (Config.AdminGroups) match too,
    -- not just Ace-allowed players.
    IsAdmin = function(src)
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer and xPlayer.isAdmin() then return true end
        -- Fall back to ACE: either the `command` ACE (superadmin convention)
        -- or the `admin` ACE node. Principals like group.admin aren't aces.
        local p = tostring(src)
        return IsPlayerAceAllowed(p, 'command') or IsPlayerAceAllowed(p, 'admin')
    end,

    ---@param itemName string
    ---@param cb function(source, itemData)
    RegisterUsableItem = function(itemName, cb)
        -- Stock ESX invokes the callback as (source, itemName) with a STRING
        -- second arg; inventory bridges may pass an item table in either
        -- position. Normalise into a fresh table so the string is never
        -- indexed and marshalled args are never mutated.
        ESX.RegisterUsableItem(itemName, function(src, item, itemData)
            local raw
            if type(itemData) == 'table' then
                raw = itemData
            elseif type(item) == 'table' then
                raw = item
            end

            local data = {}
            if raw then
                for k, v in pairs(raw) do data[k] = v end
            end
            data.name = data.name or (type(item) == 'string' and item) or itemName
            data.metadata = type(data.metadata) == 'table' and data.metadata
                or (type(data.info) == 'table' and data.info) or {}
            data.info = type(data.info) == 'table' and data.info or data.metadata
            data.slot = data.id or data.slot
            cb(src, data)
        end)
    end,

    ---@param src number
    ---@return boolean
    -- ESX's esx:playerLogout handler already dispatches esx:onPlayerLogout
    -- to the client; do not fire it a second time here.
    Logout = function(src)
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return false end
        TriggerEvent('esx:playerLogout', src)
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
