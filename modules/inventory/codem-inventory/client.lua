if GetResourceState('oxide-inventory') == 'started' then return end
if GetResourceState('codem-inventory') == 'missing' then return end

local codem = exports['codem-inventory']

olink._register('inventory', {
    ---@return table[] SlotData[]
    GetPlayerInventory = function()
        local items = {}
        local inventory = codem:GetClientPlayerInventory()
        for _, v in pairs(inventory) do
            items[#items + 1] = {
                name     = v.name,
                label    = v.label,
                count    = v.amount or v.count,
                slot     = v.slot,
                metadata = v.info or v.metadata or {},
                weight   = v.weight,
            }
        end
        return items
    end,

    ---@param item string
    ---@return number
    GetItemCount = function(item)
        local inventory = codem:GetClientPlayerInventory()
        local total = 0
        for _, v in pairs(inventory) do
            if v.name == item then
                total = total + (v.amount or v.count or 1)
            end
        end
        return total
    end,

    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(item, count)
        local inventory = codem:GetClientPlayerInventory()
        local total = 0
        for _, v in pairs(inventory) do
            if v.name == item then
                total = total + (v.amount or v.count or 1)
            end
        end
        return total >= (count or 1)
    end,
})
