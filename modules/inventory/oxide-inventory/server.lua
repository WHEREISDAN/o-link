if GetResourceState('oxide-inventory') == 'missing' then return end
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

    ---@param item string
    ---@return string
    GetImagePath = function(item)
        item = olink._stripExt(item)
        local file = LoadResourceFile('oxide-inventory', ('web/public/items/%s.png'):format(item))
        if file then return ('nui://oxide-inventory/web/public/items/%s.png'):format(item) end
        return ''
    end,
})
