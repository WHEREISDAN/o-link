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
})
