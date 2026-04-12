if GetResourceState('oxide-inventory') == 'started' then return end
if GetResourceState('ps-inventory') == 'missing' then return end

local ps = exports['ps-inventory']
local stashes = {}

olink._register('inventory', {
    ---@param src number
    ---@param item string
    ---@param count number
    ---@param slot number|nil
    ---@param metadata table|nil
    ---@return boolean
    AddItem = function(src, item, count, slot, metadata)
        local success = ps:AddItem(src, item, count, slot, metadata, 'o-link')
        return success == true
    end,

    ---@param src number
    ---@param item string
    ---@param count number
    ---@param slot number|nil
    ---@param metadata table|nil
    ---@return boolean
    RemoveItem = function(src, item, count, slot, metadata)
        local success = ps:RemoveItem(src, item, count, slot, 'o-link')
        return success == true
    end,

    ---@param src number
    ---@param slot number
    ---@return table|nil SlotData
    GetItemBySlot = function(src, slot)
        local data = ps:GetItemBySlot(src, slot)
        if not data then return nil end
        return {
            name     = data.name,
            label    = data.label or data.name,
            count    = data.amount,
            slot     = slot,
            weight   = data.weight,
            metadata = data.info or data.metadata or {},
        }
    end,

    ---@param src number
    ---@return table[] SlotData[]
    GetPlayerInventory = function(src)
        return {}
    end,

    ---@param src number
    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(src, item, count)
        return ps:HasItem(src, item, count or 1) == true
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
        stashes[id] = { label = label, slots = slots, weight = weight, owner = owner }
        return true
    end,

    ---@param src number
    ---@param stashId string
    OpenStash = function(src, stashId)
        stashId = tostring(stashId)
        local tbl = stashes[stashId] or {}
        TriggerClientEvent('o-link:inventory:ps:openStash', src, stashId, {
            weight = tbl.weight or 5000,
            slots  = tbl.slots or 20,
        })
    end,

    ---@param src number
    ---@param targetSrc number
    ---@return boolean
    OpenPlayerInventory = function(src, targetSrc)
        assert(src, 'OpenPlayerInventory: src is required')
        assert(targetSrc, 'OpenPlayerInventory: targetSrc is required')
        ps:OpenInventoryById(src, targetSrc)
        return true
    end,
})
