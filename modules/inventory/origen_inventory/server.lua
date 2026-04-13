if GetResourceState('oxide-inventory') == 'started' then return end
if GetResourceState('ox_inventory') == 'started' then return end
if GetResourceState('origen_inventory') == 'missing' then return end

local origin = exports.origen_inventory
local stashes = {}

olink._register('inventory', {
    ---@param src number
    ---@param item string
    ---@return number
    GetItemCount = function(src, item)
        return origin:getItemCount(src, item, nil, false) or 0
    end,

    ---@param src number
    ---@param item string
    ---@param count number
    ---@param slot number|nil
    ---@param metadata table|nil
    ---@return boolean
    AddItem = function(src, item, count, slot, metadata)
        local success = origin:addItem(src, item, count, metadata, slot, false)
        return success == true
    end,

    ---@param src number
    ---@param item string
    ---@param count number
    ---@param slot number|nil
    ---@param metadata table|nil
    ---@return boolean
    RemoveItem = function(src, item, count, slot, metadata)
        local success = origin:removeItem(src, item, count, metadata, slot, false)
        return success == true
    end,

    ---@param src number
    ---@param slot number
    ---@return table|nil SlotData
    GetItemBySlot = function(src, slot)
        local inv = olink.inventory.GetPlayerInventory(src)
        for _, v in pairs(inv) do
            if v.slot == slot then return v end
        end
        return nil
    end,

    ---@param src number
    ---@return table[] SlotData[]
    GetPlayerInventory = function(src)
        local playerInv = origin:GetInventory(src)
        local inv = (playerInv and playerInv.inventory) or {}
        local result = {}
        for _, v in pairs(inv) do
            if v.slot then
                result[#result + 1] = {
                    name     = v.name,
                    label    = v.label or v.name,
                    count    = v.amount or v.count,
                    slot     = v.slot,
                    metadata = v.metadata or v.info or {},
                }
            end
        end
        return result
    end,

    ---@param src number
    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(src, item, count)
        return origin:getItemCount(src, item, nil, false) > ((count or 1) - 1)
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
        stashes[id] = { id = id, label = label, slots = slots, weight = weight, owner = owner }
        origin:registerStash(id, label, slots, weight, owner)
        return true
    end,

    ---@param src number
    ---@param stashId string
    OpenStash = function(src, stashId)
        origin:OpenInventory(src, 'stash', tostring(stashId))
    end,

    ---@param src number
    ---@param targetSrc number
    ---@return boolean
    OpenPlayerInventory = function(src, targetSrc)
        assert(src, 'OpenPlayerInventory: src is required')
        assert(targetSrc, 'OpenPlayerInventory: targetSrc is required')
        origin:OpenInventory(src, 'otherplayer', targetSrc)
        return true
    end,

    ---@param item string
    ---@return table {name, label, weight, description}
    GetItemInfo = function(item)
        local data = origin:Items(item)
        if not data then return {} end
        return { name = data.name, label = data.label, weight = data.weight, description = data.description }
    end,

    ---@param item string
    ---@return string
    GetImagePath = function(item)
        item = olink._stripExt(item)
        local file = LoadResourceFile('origen_inventory', ('html/images/%s.png'):format(item))
        if file then return ('nui://origen_inventory/html/images/%s.png'):format(item) end
        return ''
    end,
})
