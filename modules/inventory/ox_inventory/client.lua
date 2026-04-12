if GetResourceState('ox_inventory') == 'missing' then return end
if GetResourceState('oxide-inventory') == 'started' then return end
if GetResourceState('qb-inventory') == 'started' then return end

local ox_inventory = exports.ox_inventory

olink._register('inventory', {
    ---@return table[] SlotData[]
    GetPlayerInventory = function()
        local items = ox_inventory:GetPlayerItems()
        if not items then return {} end
        local result = {}
        for _, item in ipairs(items) do
            result[#result + 1] = {
                name     = item.name,
                label    = item.label,
                count    = item.count,
                slot     = item.slot,
                weight   = item.weight,
                metadata = item.metadata or {},
            }
        end
        return result
    end,

    ---@param item string
    ---@return number
    GetItemCount = function(item)
        return ox_inventory:GetItemCount(item, nil, false) or 0
    end,

    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(item, count)
        return (ox_inventory:Search('count', item, nil) or 0) >= (count or 1)
    end,
})
