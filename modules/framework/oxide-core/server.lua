if not olink._guardImpl('Framework', 'oxide-core', 'oxide-core') then return end

local Oxide = exports['oxide-core']:Core()

olink._register('framework', {
    ---@return string
    GetName = function()
        return 'oxide-core'
    end,

    ---@param src number
    ---@return boolean
    GetIsPlayerLoaded = function(src)
        local player = Oxide.Functions.GetPlayer(src)
        if not player then return false end
        return player.GetCharacter() ~= nil
    end,

    ---@return number[]
    GetPlayers = function()
        local players = Oxide.Functions.GetPlayers()
        local list = {}
        for _, player in pairs(players) do
            list[#list + 1] = player.source
        end
        return list
    end,

    ---@return table[]
    GetJobs = function()
        return {}
    end,

    ---@param src number
    ---@return boolean
    IsAdmin = function(src)
        return IsPlayerAceAllowed(tostring(src), 'command')
    end,

    ---@param itemName string
    ---@param cb function(source, itemData)
    RegisterUsableItem = function(itemName, cb)
        Oxide.ItemCallbacks.Register(itemName, function(source, item, metadata)
            cb(source, {
                name = itemName,
                metadata = metadata or {},
                slot = item and item.slot or 0,
                containerId = item and item.containerId or nil,
            })
        end)
    end,

    ---@param src number
    ---@return boolean
    Logout = function(src)
        local player = Oxide.Functions.GetPlayer(src)
        if not player then return false end
        local character = player.GetCharacter()
        if character then
            TriggerEvent('oxide:core:characterUnloading', src, player, character)
        end
        player.SetActiveCharacter(nil)
        TriggerClientEvent('oxide:multichar:logoutComplete', src)
        return true
    end,

    ---@description Oxide stores items in inventory containers, not on the player
    --- object. Read inventory via the oxide-inventory adapter directly.
    ---@param src number
    ---@return table[]
    GetPlayerInventory = function(src)
        return {}
    end,
})
