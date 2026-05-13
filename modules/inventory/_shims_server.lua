-- Underscore prefix keeps this out of the `**/server.lua` adapter glob so it
-- loads once via its explicit fxmanifest entry, after all adapters.

if not olink.inventory then return end

local realGetImagePath = olink.inventory.GetImagePath

olink._register('inventory', {
    GetImagePath = function(item)
        local base = Config and Config.ImageBaseUrl
        if type(base) == 'string' and base ~= '' and type(item) == 'string' and item ~= '' then
            if not base:match('/$') then base = base .. '/' end
            local stripped = item:gsub('%.png$', ''):gsub('%.webp$', '')
            return base .. stripped .. '.png'
        end
        return realGetImagePath and realGetImagePath(item) or ''
    end,
}, 'o-link')

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
