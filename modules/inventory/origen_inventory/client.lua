if GetResourceState('oxide-inventory') == 'started' then return end
if GetResourceState('ox_inventory') == 'started' then return end
if GetResourceState('origen_inventory') == 'missing' then return end

local origin = exports.origen_inventory

olink._register('inventory', {
    ---@return table[] SlotData[]
    GetPlayerInventory = function()
        local inventory = origin:GetInventory()
        local result = {}
        for _, v in pairs(inventory or {}) do
            result[#result + 1] = {
                name     = v.name,
                label    = v.label,
                count    = v.amount or v.count,
                slot     = v.slot,
                metadata = v.metadata or v.info or {},
                weight   = v.weight,
            }
        end
        return result
    end,

    ---@param item string
    ---@return number
    GetItemCount = function(item)
        local inv = origin:Search('count', item)
        return (inv and inv.count) or 0
    end,

    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(item, count)
        local inv = origin:Search('count', item)
        return (inv and inv.count or 0) >= (count or 1)
    end,
})
