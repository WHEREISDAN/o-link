if GetResourceState('qb-inventory') ~= 'started' then return end
if GetResourceState('oxide-inventory') == 'started' then return end

local qb = exports['qb-inventory']

-- v1 legacy stash open support
RegisterNetEvent('o-link:inventory:qb:openStash', function(id, data)
    if source ~= 65535 then return end
    TriggerEvent('inventory:client:SetCurrentStash', id)
    TriggerServerEvent('inventory:server:OpenInventory', 'stash', id, {
        maxweight = data.weight,
        slots     = data.slots,
    })
end)

olink._register('inventory', {
    ---@return table[] SlotData[]
    GetPlayerInventory = function()
        local items = qb:GetPlayerItems()
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
        local items = qb:GetPlayerItems()
        if not items then return 0 end
        local total = 0
        for _, slot in pairs(items) do
            if slot and slot.name == item then
                total = total + (slot.amount or 1)
            end
        end
        return total
    end,

    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(item, count)
        return qb:HasItem(item, count or 1) == true
    end,
})
