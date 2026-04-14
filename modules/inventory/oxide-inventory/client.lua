if GetResourceState('oxide-inventory') == 'missing' then return end

local Oxide = exports['oxide-core']:Core()

olink._register('inventory', {
    ---@return table[] SlotData[]
    GetPlayerInventory = function()
        local inventory = LocalPlayer.state['oxide:inventory']
        if not inventory or not inventory.containers then return {} end
        local items = {}
        for _, container in ipairs(inventory.containers) do
            for _, item in ipairs(container.items or {}) do
                if item then
                    items[#items + 1] = {
                        name     = item.name,
                        label    = item.label,
                        count    = item.amount,
                        slot     = item.slot,
                        metadata = item.metadata or {},
                    }
                end
            end
        end
        return items
    end,

    ---@param item string
    ---@return number
    GetItemCount = function(item)
        local inventory = LocalPlayer.state['oxide:inventory']
        if not inventory or not inventory.containers then return 0 end
        local count = 0
        for _, container in ipairs(inventory.containers) do
            for _, slot in ipairs(container.items or {}) do
                if slot and slot.name == item then
                    count = count + (slot.amount or 1)
                end
            end
        end
        return count
    end,

    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(item, count)
        count = count or 1
        local inventory = LocalPlayer.state['oxide:inventory']
        if not inventory or not inventory.containers then return false end
        local total = 0
        for _, container in ipairs(inventory.containers) do
            for _, slot in ipairs(container.items or {}) do
                if slot and slot.name == item then
                    total = total + (slot.amount or 1)
                end
            end
        end
        return total >= count
    end,

    ---@param item string
    ---@return table {name, label, weight, description}
    GetItemInfo = function(item)
        local data = Oxide.GetItem and Oxide.GetItem(item)
        if not data then return {} end
        return {
            name = data.name or item,
            label = data.label or item,
            weight = data.weight,
            description = data.description,
        }
    end,

    ---@param item string
    ---@return string
    GetImagePath = function(item)
        item = olink._stripExt(item)
        local file = LoadResourceFile('oxide-inventory', ('web/public/items/%s.png'):format(item))
        if file then return ('nui://oxide-inventory/web/public/items/%s.png'):format(item) end
        return ''
    end,
})
