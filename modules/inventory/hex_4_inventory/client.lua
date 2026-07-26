if not olink._guardImpl('Inventory', 'hex_4_inventory', 'hex_4_inventory') then return end
if not olink._hasOverride('Inventory') and GetResourceState('oxide-inventory') == 'started' then return end

-- hex_4_inventory renders the framework's own item store, so client reads go
-- through ESX/QB player data rather than hex exports.
local ESX = GetResourceState('es_extended') == 'started' and exports['es_extended']:getSharedObject() or nil
local QBCore = not ESX and GetResourceState('qb-core') == 'started' and exports['qb-core']:GetCoreObject() or nil

---@return table[]
local function rawItems()
    if ESX then
        local data = ESX.GetPlayerData()
        return (data and data.inventory) or {}
    end
    if QBCore then
        local data = QBCore.Functions.GetPlayerData()
        return (data and data.items) or {}
    end
    return {}
end

olink._register('inventory', {
    ---@return table[] SlotData[]
    GetPlayerInventory = function()
        local result = {}
        for _, v in pairs(rawItems()) do
            local count = v.count or v.amount or 0
            if v.name and count > 0 then
                result[#result + 1] = {
                    name     = v.name,
                    label    = v.label or v.name,
                    count    = count,
                    slot     = v.slot or 0,
                    metadata = v.info or v.metadata or {},
                    weight   = v.weight,
                }
            end
        end
        return result
    end,

    ---@param item string
    ---@return number
    GetItemCount = function(item)
        local total = 0
        for _, v in pairs(rawItems()) do
            if v.name == item then
                total = total + (v.count or v.amount or 0)
            end
        end
        return total
    end,

    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(item, count)
        return olink.inventory.GetItemCount(item) >= (count or 1)
    end,

    ---@param item string
    ---@return table {name, label, weight, description}
    GetItemInfo = function(item)
        local data = QBCore and QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[item]
        if data then
            return { name = data.name, label = data.label, weight = data.weight, description = data.description }
        end
        for _, v in pairs(rawItems()) do
            if v.name == item then
                return { name = v.name, label = v.label or v.name, weight = v.weight }
            end
        end
        return {}
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

    ---@return table All item definitions (base ESX has no client item registry)
    Items = function()
        if QBCore then return (QBCore.Shared and QBCore.Shared.Items) or {} end
        return {}
    end,
})
