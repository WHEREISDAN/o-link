if not olink._guardImpl('Inventory', 'hex_4_inventory', 'hex_4_inventory') then return end
if not olink._hasOverride('Inventory') and GetResourceState('oxide-inventory') == 'started' then return end

-- hex_4_inventory is a UI layer over the framework's own item store (its UI
-- renders ESX/QB player inventory data), so item mutations go through the
-- framework core. Hex's exports only cover plate changes and opening
-- arbitrary inventories; its AddItemToInventory/RemoveItemFromInventory
-- exports take undocumented playerObject/itemData tables and are not used.
local hex = exports['hex_4_inventory']
local ESX = GetResourceState('es_extended') == 'started' and exports['es_extended']:getSharedObject() or nil
local QBCore = not ESX and GetResourceState('qb-core') == 'started' and exports['qb-core']:GetCoreObject() or nil
local stashes = {}

---@param src number
---@param item string
---@return number
local function getTotalCount(src, item)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return 0 end
        local data = xPlayer.getInventoryItem(item)
        return (data and data.count) or 0
    end
    if QBCore then
        local player = QBCore.Functions.GetPlayer(src)
        if not player then return 0 end
        local total = 0
        for _, v in pairs(player.PlayerData.items or {}) do
            if v and v.name == item then
                total = total + (v.amount or v.count or 0)
            end
        end
        return total
    end
    return 0
end

olink._register('inventory', {
    ---@param src number
    ---@param item string
    ---@return number
    GetItemCount = function(src, item)
        return getTotalCount(src, item)
    end,

    ---@param src number
    ---@param item string
    ---@param count number
    ---@param slot number|nil
    ---@param metadata table|nil
    ---@return boolean
    AddItem = function(src, item, count, slot, metadata)
        if ESX then
            local xPlayer = ESX.GetPlayerFromId(src)
            if not xPlayer then return false end
            if xPlayer.canCarryItem and not xPlayer.canCarryItem(item, count) then return false end
            xPlayer.addInventoryItem(item, count)
            return true
        end
        if QBCore then
            local player = QBCore.Functions.GetPlayer(src)
            if not player then return false end
            local success = player.Functions.AddItem(item, count, slot, metadata)
            return success and true or false
        end
        return false
    end,

    ---@param src number
    ---@param item string
    ---@param count number
    ---@param slot number|nil
    ---@param metadata table|nil
    ---@return boolean
    RemoveItem = function(src, item, count, slot, metadata)
        if ESX then
            local xPlayer = ESX.GetPlayerFromId(src)
            if not xPlayer then return false end
            local data = xPlayer.getInventoryItem(item)
            if ((data and data.count) or 0) < count then return false end
            xPlayer.removeInventoryItem(item, count)
            return true
        end
        if QBCore then
            local player = QBCore.Functions.GetPlayer(src)
            if not player then return false end
            local success = player.Functions.RemoveItem(item, count, slot)
            return success and true or false
        end
        return false
    end,

    ---@param src number
    ---@param slot number
    ---@return table|nil SlotData (base ESX has no slot storage; QB only)
    GetItemBySlot = function(src, slot)
        if not QBCore then return nil end
        local player = QBCore.Functions.GetPlayer(src)
        local data = player and player.PlayerData.items and player.PlayerData.items[slot]
        if not data then return nil end
        return {
            name     = data.name,
            label    = data.label or data.name,
            count    = data.amount or data.count,
            slot     = slot,
            weight   = data.weight,
            metadata = data.info or data.metadata or {},
        }
    end,

    ---@param src number
    ---@return table[] SlotData[]
    GetPlayerInventory = function(src)
        return olink.framework.GetPlayerInventory(src) or {}
    end,

    ---@param src number
    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(src, item, count)
        return getTotalCount(src, item) >= (count or 1)
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
        stashes[id] = { label = label, slots = slots, weight = weight, owner = owner }
        return true
    end,

    ---@param src number
    ---@param stashId string
    OpenStash = function(src, stashId)
        stashId = tostring(stashId)
        local tbl = stashes[stashId] or {}
        -- 'fraction' is hex's documented type for arbitrary named shared storage.
        -- weight = false disables hex's cap; hex weight units are undocumented,
        -- so registered stash weights are not forwarded.
        hex:OpenInventory(src, {
            id     = stashId,
            type   = 'fraction',
            title  = tbl.label or stashId,
            weight = false,
        })
    end,

    ---@param item string
    ---@return table
    GetItemInfo = function(item)
        local data
        if ESX then
            data = ESX.Items and ESX.Items[item]
        elseif QBCore then
            data = QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[item]
        end
        if not data then return {} end
        return {
            name = data.name or item,
            label = data.label,
            weight = data.weight,
            description = data.description,
            stack = data.unique == nil and true or (not data.unique),
            image = olink.inventory.GetImagePath and olink.inventory.GetImagePath(item) or nil,
        }
    end,

    ---@param item string
    ---@return string
    GetImagePath = function(item)
        item = olink._stripExt(item)
        for _, fmt in ipairs({ 'html/images/%s.png', 'images/%s.png', 'web/images/%s.png', 'ui/images/%s.png' }) do
            local rel = fmt:format(item)
            if LoadResourceFile('hex_4_inventory', rel) then
                return ('nui://hex_4_inventory/%s'):format(rel)
            end
        end
        return 'https://avatars.githubusercontent.com/u/47620135'
    end,

    ---@return table All item definitions
    Items = function()
        if ESX then return ESX.Items or {} end
        if QBCore then return (QBCore.Shared and QBCore.Shared.Items) or {} end
        return {}
    end,

    ---@param src number
    ---@param item string
    ---@param count number|nil
    ---@return boolean
    CanCarryItem = function(src, item, count)
        if ESX then
            local xPlayer = ESX.GetPlayerFromId(src)
            if xPlayer and xPlayer.canCarryItem then
                return xPlayer.canCarryItem(item, count or 1) == true
            end
        end
        return true
    end,

    ---@param oldPlate string
    ---@param newPlate string
    ---@return boolean
    UpdatePlate = function(oldPlate, newPlate)
        hex:ChangeInventoryPlate(oldPlate, newPlate)
        if GetResourceState('jg-mechanic') == 'started' then
            exports['jg-mechanic']:vehiclePlateUpdated(oldPlate, newPlate)
        end
        return true
    end,

    -- Unsupported features (no documented hex export; base framework has no path)
    SetMetadata = function() return false end,
    OpenPlayerInventory = function() return false end,
    GetStashItems = function() return {} end,
    RemoveStashItem = function() return false end,
    ClearStash = function() return false end,
    AddTrunkItems = function() return false end,
    OpenShop = function() end,
    RegisterShop = function() return false end,
})
