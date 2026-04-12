if GetResourceState('oxide-inventory') == 'started' then return end
if GetResourceState('ps-inventory') ~= 'started' then return end

-- Server relays stash open via this event
RegisterNetEvent('o-link:inventory:ps:openStash', function(id, data)
    if source ~= 65535 then return end
    TriggerEvent('ps-inventory:client:SetCurrentStash', id)
    TriggerServerEvent('ps-inventory:server:OpenInventory', 'stash', id, { maxweight = data.weight, slots = data.slots })
end)

local ps = exports['ps-inventory']

olink._register('inventory', {
    ---@return table[] SlotData[]
    GetPlayerInventory = function()
        return {}
    end,

    ---@param item string
    ---@return number
    GetItemCount = function(item)
        return 0
    end,

    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(item, count)
        return ps:HasItem(item, count or 1) == true
    end,
})
