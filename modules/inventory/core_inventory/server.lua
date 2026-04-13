if GetResourceState('oxide-inventory') == 'started' then return end
if GetResourceState('core_inventory') == 'missing' then return end

local core = exports.core_inventory
local QBCore = exports['qb-core']:GetCoreObject()
local stashes = {}

olink._register('inventory', {
    ---@param src number
    ---@param item string
    ---@return number
    GetItemCount = function(src, item)
        return core:getItemCount(src, item) or 0
    end,

    ---@param src number
    ---@param item string
    ---@param count number
    ---@param slot number|nil
    ---@param metadata table|nil
    ---@return boolean
    AddItem = function(src, item, count, slot, metadata)
        local success = core:addItem(src, item, count, metadata)
        return success ~= false and success ~= nil
    end,

    ---@param src number
    ---@param item string
    ---@param count number
    ---@param slot number|nil
    ---@param metadata table|nil
    ---@return boolean
    RemoveItem = function(src, item, count, slot, metadata)
        if slot then
            local identifier = olink.character.GetIdentifier(src)
            if identifier then
                identifier = string.gsub(identifier, ':', '')
                return core:removeItemExact('content-' .. identifier, slot, count) ~= false
            end
        end
        core:removeItem(src, item, count)
        return true
    end,

    ---@param src number
    ---@param slot number
    ---@return table|nil SlotData
    GetItemBySlot = function(src, slot)
        local inv = olink.inventory.GetPlayerInventory(src)
        for _, v in pairs(inv) do
            if (v.slot == slot) or (v.id == slot) then
                return v
            end
        end
        return nil
    end,

    ---@param src number
    ---@return table[] SlotData[]
    GetPlayerInventory = function(src)
        local playerItems = core:getInventory(src)
        local result = {}
        for _, v in pairs(playerItems or {}) do
            result[#result + 1] = {
                name     = v.name,
                label    = v.label or v.name,
                count    = v.count or v.amount,
                slot     = v.id or v.slot,
                metadata = v.metadata or v.info or {},
            }
        end
        return result
    end,

    ---@param src number
    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(src, item, count)
        local c = core:getItemCount(src, item) or 0
        return c >= (count or 1)
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
        local tbl = stashes[stashId] or { slots = 30, weight = 50000 }
        core:openInventory(src, stashId, 'stash', tbl.slots or 30, tbl.weight or 50000, true, nil, false)
    end,

    ---@param src number
    ---@param targetSrc number
    ---@return boolean
    OpenPlayerInventory = function(src, targetSrc)
        assert(src, 'OpenPlayerInventory: src is required')
        assert(targetSrc, 'OpenPlayerInventory: targetSrc is required')
        local identifier = olink.character.GetIdentifier(targetSrc)
        if not identifier then return false end
        core:openInventory(src, 'stash-' .. string.gsub(identifier, ':', ''), 'stash', nil, nil, true, nil, false)
        return true
    end,

    ---@param item string
    ---@return table {name, label, weight, description}
    GetItemInfo = function(item)
        local data = QBCore.Shared.Items[item]
        if not data then return {} end
        return { name = data.name, label = data.label, weight = data.weight, description = data.description }
    end,

    ---@param item string
    ---@return string
    GetImagePath = function(item)
        item = olink._stripExt(item)
        local file = LoadResourceFile('core_inventory', ('html/img/%s.png'):format(item))
        if file then return ('nui://core_inventory/html/img/%s.png'):format(item) end
        return ''
    end,
})
