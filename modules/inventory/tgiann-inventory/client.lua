if GetResourceState('oxide-inventory') == 'started' then return end
if GetResourceState('tgiann-inventory') == 'missing' then return end

local tgiann = exports['tgiann-inventory']

olink._register('inventory', {
    ---@return table[] SlotData[]
    GetPlayerInventory = function()
        local inventory = tgiann:GetPlayerItems()
        local result = {}
        for _, v in pairs(inventory or {}) do
            result[#result + 1] = {
                name     = v.name,
                label    = v.label or v.name,
                count    = v.amount,
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
        return tgiann:GetItemCount(item, nil, false) or 0
    end,

    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(item, count)
        return tgiann:HasItem(item, count or 1) == true
    end,

    ---@param item string
    ---@return table {name, label, weight, description}
    GetItemInfo = function(item)
        local items = tgiann:GetItemList()
        if not items or not items[item] then return {} end
        local data = items[item]
        return { name = data.name, label = data.label, weight = data.weight, description = data.description }
    end,

    ---@param item string
    ---@return string
    GetImagePath = function(item)
        item = olink._stripExt(item)
        local png = LoadResourceFile('inventory_images', ('images/%s.png'):format(item))
        if png then return ('nui://inventory_images/images/%s.png'):format(item) end
        local webp = LoadResourceFile('inventory_images', ('images/%s.webp'):format(item))
        if webp then return ('nui://inventory_images/images/%s.webp'):format(item) end
        return ''
    end,
})
