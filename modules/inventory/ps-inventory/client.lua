if GetResourceState('oxide-inventory') == 'started' then return end
if GetResourceState('ps-inventory') == 'missing' then return end

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

    ---@param item string
    ---@return table {name, label, weight, description}
    GetItemInfo = function(item)
        local data = QBCore and QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[item]
        if not data then return {} end
        return { name = data.name, label = data.label, weight = data.weight, description = data.description }
    end,

    ---@param item string
    ---@return string
    GetImagePath = function(item)
        item = olink._stripExt(item)
        local file = LoadResourceFile('ps-inventory', ('html/images/%s.png'):format(item))
        if file then return ('nui://ps-inventory/html/images/%s.png'):format(item) end
        return ''
    end,
})
