if GetResourceState('oxide-inventory') == 'started' then return end
if GetResourceState('core_inventory') == 'missing' then return end

local core = exports.core_inventory

olink._register('inventory', {
    ---@return table[] SlotData[]
    GetPlayerInventory = function()
        local playerItems = core:getInventory()
        local result = {}
        for _, v in pairs(playerItems or {}) do
            result[#result + 1] = {
                name     = v.name,
                label    = v.label or v.name,
                count    = v.count or v.amount,
                slot     = v.id or v.slot,
                metadata = v.metadata or v.info or {},
            }
        end
        return result
    end,

    ---@param item string
    ---@return number
    GetItemCount = function(item)
        return core:getItemCount(item) or 0
    end,

    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(item, count)
        return (core:getItemCount(item) or 0) >= (count or 1)
    end,
})
