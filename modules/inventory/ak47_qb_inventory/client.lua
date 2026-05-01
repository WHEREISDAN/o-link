if not olink._guardImpl('Inventory', 'ak47_qb_inventory', 'ak47_qb_inventory') then return end
if not olink._hasOverride('Inventory') and GetResourceState('oxide-inventory') == 'started' then return end
if not olink._hasOverride('Inventory') and GetResourceState('qb-inventory') == 'started' then return end

local ak47 = exports['ak47_qb_inventory']
local QBCore = exports['qb-core']:GetCoreObject()

olink._register('inventory', {
    ---@return table[] SlotData[]
    GetPlayerInventory = function()
        local items = ak47:GetPlayerItems()
        if not items then return {} end
        local result = {}
        for _, item in pairs(items) do
            if item and item.name then
                result[#result + 1] = {
                    name     = item.name,
                    label    = item.label or item.name,
                    count    = item.amount,
                    slot     = item.slot,
                    weight   = item.weight,
                    metadata = item.info or {},
                }
            end
        end
        return result
    end,

    ---@param item string
    ---@return number
    GetItemCount = function(item)
        local amount = ak47:GetAmount(item)
        return tonumber(amount) or 0
    end,

    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(item, count)
        local amount = tonumber(ak47:GetAmount(item)) or 0
        return amount >= (count or 1)
    end,

    ---@param item string
    ---@return table {name, label, weight, description}
    GetItemInfo = function(item)
        local data = QBCore and QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[item]
        if not data then return {} end
        return { name = data.name, label = data.label, weight = data.weight, description = data.description }
    end,

    ---@param item string
    ---@return string
    GetImagePath = function(item)
        item = olink._stripExt(item)
        local file = LoadResourceFile('ak47_qb_inventory', ('html/images/%s.png'):format(item))
        if file then return ('nui://ak47_qb_inventory/html/images/%s.png'):format(item) end
        return ''
    end,

    ---@return table All item definitions
    Items = function()
        local core = QBCore and QBCore.Shared and QBCore.Shared.Items
        return core or {}
    end,
})
