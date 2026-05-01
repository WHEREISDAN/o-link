if not olink._guardImpl('Inventory', 'oxide-inventory', 'oxide-inventory') then return end
if GetResourceState('oxide-core') == 'missing' then return end

local Oxide = exports['oxide-core']:Core()
local InventoryAPI

local function GetInv()
    if not InventoryAPI then
        InventoryAPI = exports['oxide-inventory']:Inventory()
    end
    return InventoryAPI
end

local function GetCharId(src)
    local player = Oxide.Functions.GetPlayer(src)
    if not player then return nil end
    local character = player.GetCharacter()
    if not character then return nil end
    return character.charId
end

local stashes = {}

olink._register('inventory', {
    ---@param src number
    ---@param item string
    ---@return number
    GetItemCount = function(src, item)
        local charId = GetCharId(src)
        if not charId then return 0 end
        local items = GetInv().GetAllItems(charId)
        local total = 0
        for _, v in ipairs(items or {}) do
            if v.name == item then
                total = total + (v.amount or v.count or 0)
            end
        end
        return total
    end,

    ---@param src number
    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(src, item, count)
        local charId = GetCharId(src)
        if not charId then return false end
        local items = GetInv().GetAllItems(charId)
        local total = 0
        for _, v in ipairs(items or {}) do
            if v.name == item then
                total = total + (v.amount or v.count or 0)
            end
        end
        return total >= (count or 1)
    end,

    ---@param src number
    ---@param item string
    ---@param count number
    ---@param slot number|nil
    ---@param metadata table|nil
    ---@return boolean
    AddItem = function(src, item, count, slot, metadata)
        local charId = GetCharId(src)
        if not charId then return false end
        local success = GetInv().AddItem(charId, item, count, metadata)
        return success == true
    end,

    ---@param src number
    ---@param item string
    ---@param count number
    ---@param slot number|nil
    ---@param metadata table|nil
    ---@return boolean
    RemoveItem = function(src, item, count, slot, metadata)
        item = type(item) == 'table' and item.name or item
        local charId = GetCharId(src)
        if not charId then return false end

        if slot and slot > 0 then
            local inv = GetInv()
            local items = inv.GetAllItems(charId)
            local containerId
            for _, v in ipairs(items or {}) do
                if v.slot == slot and v.name == item then
                    containerId = v.containerId
                    break
                end
            end
            if containerId then
                return inv.RemoveFromSlot(charId, containerId, slot, count) ~= nil
            end
        end

        local success = GetInv().RemoveItem(charId, item, count)
        return success == true
    end,

    ---@param src number
    ---@param slot number
    ---@return table|nil SlotData
    GetItemBySlot = function(src, slot)
        local charId = GetCharId(src)
        if not charId then return nil end
        local inv = GetInv().GetInventory(charId)
        if not inv then return nil end
        for _, container in ipairs(inv) do
            for _, item in ipairs(container.items or {}) do
                if item.slot == slot then
                    return {
                        name     = item.name,
                        label    = item.label,
                        count    = item.amount,
                        slot     = item.slot,
                        weight   = item.weight,
                        metadata = item.metadata or {},
                    }
                end
            end
        end
        return nil
    end,

    ---@param src number
    ---@return table[] SlotData[]
    GetPlayerInventory = function(src)
        local charId = GetCharId(src)
        if not charId then return {} end
        return GetInv().GetAllItems(charId) or {}
    end,

    ---@param src number
    ---@param targetSrc number
    ---@return boolean
    OpenPlayerInventory = function(src, targetSrc)
        return GetInv().OpenPlayerInventory(src, targetSrc)
    end,

    ---@param id string
    ---@param label string
    ---@param slots number
    ---@param weight number
    ---@param owner string|nil
    ---@return boolean
    RegisterStash = function(id, label, slots, weight, owner)
        id = tostring(id)
        if stashes[id] then return true end
        stashes[id] = true
        GetInv().RegisterStash(id, label, slots, weight, owner)
        return true
    end,

    ---@param src number
    ---@param stashId string
    ---@return nil
    OpenStash = function(src, stashId)
        TriggerClientEvent('oxide:inventory:openStash', src, tostring(stashId))
    end,

    ---@param item string
    ---@return table {name, label, weight, description}
    GetItemInfo = function(item)
        local data = Oxide.GetItem and Oxide.GetItem(item)
        if not data then return {} end
        return {
            name = data.name or item,
            label = data.label or item,
            weight = data.weight,
            description = data.description,
        }
    end,

    ---@param src number
    ---@param item string
    ---@param slot number
    ---@param metadata table
    ---@return boolean
    SetMetadata = function(src, item, slot, metadata)
        local charId = GetCharId(src)
        if not charId then return false end
        if type(metadata) ~= 'table' then return false end
        local inv = GetInv()
        local items = inv.GetAllItems(charId)
        local containerId
        for _, v in ipairs(items or {}) do
            if v.slot == slot and v.name == item then
                containerId = v.containerId
                break
            end
        end
        if not containerId then return false end
        for key, value in pairs(metadata) do
            inv.SetItemMetadata(charId, containerId, slot, key, value)
        end
        return true
    end,

    ---@param item string
    ---@return string
    GetImagePath = function(item)
        item = olink._stripExt(item)
        local file = LoadResourceFile('oxide-inventory', ('web/public/items/%s.png'):format(item))
        if file then return ('nui://oxide-inventory/web/public/items/%s.png'):format(item) end
        return ''
    end,

    ---@return table All item definitions
    Items = function()
        return Oxide.Items or {}
    end,

    ---@param src number
    ---@param item string
    ---@param count number|nil
    ---@return boolean
    CanCarryItem = function(src, item, count)
        local charId = GetCharId(src)
        if not charId then return false end
        local ok = GetInv().CanAddItem(charId, item, count or 1)
        return ok == true
    end,

    ---@param id string
    ---@return table[]
    GetStashItems = function(id)
        return GetInv().GetStashItems(tostring(id)) or {}
    end,

    ---@param id string
    ---@param item string
    ---@param count number
    ---@return boolean
    RemoveStashItem = function(id, item, count)
        return GetInv().RemoveStashItem(tostring(id), item, count) ~= nil
    end,

    ---@param id string
    ---@param item string
    ---@param count number
    ---@param metadata table|nil
    ---@return boolean
    AddStashItem = function(id, item, count, metadata)
        return GetInv().AddStashItem(tostring(id), item, count or 1, metadata) ~= nil
    end,

    ---@param id string
    ---@param _type string|nil unused
    ---@return boolean
    ClearStash = function(id, _type)
        id = tostring(id)
        local items = GetInv().GetStashItems(id)
        for _, v in ipairs(items or {}) do
            GetInv().RemoveStashItem(id, v.name, v.amount or v.count or 1)
        end
        return true
    end,

    ---@param identifier string plate or trunk identifier
    ---@param items table[]
    ---@return boolean
    AddTrunkItems = function(identifier, items)
        local trunkId = 'trunk_' .. tostring(identifier)
        if not stashes[trunkId] then
            stashes[trunkId] = true
            GetInv().RegisterStash(trunkId, 'Vehicle Trunk', 50, 100000, nil)
        end
        Wait(100)
        local inv = GetInv()
        for _, item in ipairs(items or {}) do
            inv.AddStashItem(trunkId, item.name, item.count or item.amount or 1, item.metadata)
        end
        return true
    end,

    ---@param oldPlate string
    ---@param newPlate string
    ---@return boolean
    UpdatePlate = function(oldPlate, newPlate)
        MySQL.update.await('UPDATE containers SET stash_id = ? WHERE stash_id = ?', {
            'trunk_' .. newPlate, 'trunk_' .. oldPlate
        })
        return true
    end,

    ---@param src number
    ---@param shopTitle string
    OpenShop = function(src, shopTitle)
        TriggerClientEvent('oxide:inventory:openShop', src, shopTitle)
    end,

    ---@param shopTitle string
    ---@param shopInventory table
    ---@param shopCoords table|nil
    ---@param shopGroups table|nil
    RegisterShop = function(shopTitle, shopInventory, shopCoords, shopGroups)
        TriggerClientEvent('oxide:inventory:registerShop', -1, shopTitle, shopInventory, shopCoords, shopGroups)
    end,
})
