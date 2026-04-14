if GetResourceState('oxide-inventory') == 'started' then return end
if GetResourceState('qs-inventory') == 'missing' then return end

local quasar = exports['qs-inventory']

olink._register('inventory', {
    ---@return table[] SlotData[]
    GetPlayerInventory = function()
        local inventory = quasar:getUserInventory()
        local result = {}
        for _, v in pairs(inventory or {}) do
            result[#result + 1] = {
                name     = v.name,
                label    = v.label,
                count    = v.amount or v.count,
                slot     = v.slot,
                metadata = v.info or v.metadata or {},
                weight   = v.weight,
            }
        end
        return result
    end,

    ---@param item string
    ---@return number
    GetItemCount = function(item)
        return quasar:Search(item) or 0
    end,

    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(item, count)
        local c = quasar:Search(item) or 0
        return c >= (count or 1)
    end,

    ---@param item string
    ---@return table {name, label, weight, description}
    GetItemInfo = function(item)
        local items = quasar:GetItemList()
        if not items or not items[item] then return {} end
        local data = items[item]
        return { name = data.name, label = data.label, weight = data.weight, description = data.description }
    end,

    ---@param item string
    ---@return string
    GetImagePath = function(item)
        item = olink._stripExt(item)
        local file = LoadResourceFile('qs-inventory', ('html/images/%s.png'):format(item))
        if file then return ('nui://qs-inventory/html/images/%s.png'):format(item) end
        return ''
    end,
})
