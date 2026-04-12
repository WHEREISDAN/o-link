if GetResourceState('ox_inventory') == 'missing' then return end
if GetResourceState('oxide-inventory') == 'started' then return end
if GetResourceState('qb-inventory') == 'started' then return end

local ox_inventory = exports.ox_inventory

local stashes = {}

olink._register('inventory', {
    ---@param src number
    ---@param item string
    ---@param count number
    ---@param slot number|nil
    ---@param metadata table|nil
    ---@return boolean
    AddItem = function(src, item, count, slot, metadata)
        if not ox_inventory:CanCarryItem(src, item, count, metadata) then return false end
        local success = ox_inventory:AddItem(src, item, count, metadata, slot)
        return success == true
    end,

    ---@param src number
    ---@param item string
    ---@param count number
    ---@param slot number|nil
    ---@param metadata table|nil
    ---@return boolean
    RemoveItem = function(src, item, count, slot, metadata)
        local success = ox_inventory:RemoveItem(src, item, count, metadata, slot)
        return success == true
    end,

    ---@param src number
    ---@param slot number
    ---@return table|nil SlotData {name, label, count, slot, weight, metadata}
    GetItemBySlot = function(src, slot)
        local data = ox_inventory:GetSlot(src, slot)
        if not data then return nil end
        return {
            name     = data.name,
            label    = data.label,
            count    = data.count,
            slot     = data.slot,
            weight   = data.weight,
            metadata = data.metadata or {},
        }
    end,

    ---@param src number
    ---@return table[] SlotData[]
    GetPlayerInventory = function(src)
        local items = ox_inventory:GetInventoryItems(src, false)
        if not items then return {} end
        local result = {}
        for _, item in ipairs(items) do
            result[#result + 1] = {
                name     = item.name,
                label    = item.label,
                count    = item.count,
                slot     = item.slot,
                weight   = item.weight,
                metadata = item.metadata or {},
            }
        end
        return result
    end,

    ---@param src number
    ---@param targetSrc number
    ---@return boolean
    OpenPlayerInventory = function(src, targetSrc)
        assert(src, 'OpenPlayerInventory: src is required')
        assert(targetSrc, 'OpenPlayerInventory: targetSrc is required')
        ox_inventory:forceOpenInventory(src, 'player', targetSrc)
        return true
    end,

    ---@param id string
    ---@param label string
    ---@param slots number
    ---@param weight number
    ---@param owner string|nil
    ---@return boolean
    RegisterStash = function(id, label, slots, weight, owner)
        id = tostring(id)
        if stashes[id] then return true end
        stashes[id] = true
        ox_inventory:RegisterStash(id, label, slots, weight, owner)
        return true
    end,

    ---@param src number
    ---@param stashId string
    ---@return nil
    OpenStash = function(src, stashId)
        ox_inventory:forceOpenInventory(src, 'stash', tostring(stashId))
    end,
})
