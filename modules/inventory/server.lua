-- Inventory event sync shim. Fires an inventory-updated event to the client
-- on AddItem/RemoveItem regardless of which adapter registered.
-- Loads after adapters via alphabetical glob order.

if not olink.inventory then return end
if olink._inventorySyncLoaded then return end
olink._inventorySyncLoaded = true

local realAdd = olink.inventory.AddItem
local realRemove = olink.inventory.RemoveItem

local function fire(src, action, item, count, slot, metadata)
    TriggerClientEvent('o-link:client:inventory:updateInventory', src, {
        action   = action,
        item     = item,
        count    = count,
        slot     = slot,
        metadata = metadata,
    })
end

if realAdd then
    olink._register('inventory', {
        AddItem = function(src, item, count, slot, metadata)
            local ok = realAdd(src, item, count, slot, metadata)
            if ok then fire(src, 'add', item, count, slot, metadata) end
            return ok
        end,
    })
end

if realRemove then
    olink._register('inventory', {
        RemoveItem = function(src, item, count, slot, metadata)
            local ok = realRemove(src, item, count, slot, metadata)
            if ok then fire(src, 'remove', item, count, slot, metadata) end
            return ok
        end,
    })
end
