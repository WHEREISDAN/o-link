if GetResourceState('oxide-inventory') == 'started' then return end
if GetResourceState('tgiann-inventory') == 'missing' then return end

local tgiann = exports['tgiann-inventory']
local stashes = {}

olink._register('inventory', {
    ---@param src number
    ---@param item string
    ---@return number
    GetItemCount = function(src, item)
        local inventory = tgiann:GetPlayerItems(src)
        local total = 0
        for k, v in pairs(inventory or {}) do
            if tonumber(k) and v.name == item then
                total = total + (v.amount or 0)
            end
        end
        return total
    end,

    ---@param src number
    ---@param item string
    ---@param count number
    ---@param slot number|nil
    ---@param metadata table|nil
    ---@return boolean
    AddItem = function(src, item, count, slot, metadata)
        if not tgiann:CanCarryItem(src, item, count) then return false end
        local success = tgiann:AddItem(src, item, count, slot, metadata, false)
        return success == true
    end,

    ---@param src number
    ---@param item string
    ---@param count number
    ---@param slot number|nil
    ---@param metadata table|nil
    ---@return boolean
    RemoveItem = function(src, item, count, slot, metadata)
        local success = tgiann:RemoveItem(src, item, count, slot, metadata)
        return success == true
    end,

    ---@param src number
    ---@param slot number
    ---@return table|nil SlotData
    GetItemBySlot = function(src, slot)
        local data = tgiann:GetItemBySlot(src, slot)
        if not data then return nil end
        return {
            name     = data.name,
            label    = data.label or data.name,
            count    = data.amount or data.count,
            slot     = slot,
            weight   = data.weight,
            metadata = data.info or data.metadata or {},
        }
    end,

    ---@param src number
    ---@return table[] SlotData[]
    GetPlayerInventory = function(src)
        local inventory = tgiann:GetPlayerItems(src)
        local result = {}
        for k, v in pairs(inventory or {}) do
            if tonumber(k) then
                result[#result + 1] = {
                    name     = v.name,
                    label    = v.name,
                    count    = v.amount,
                    slot     = v.slot,
                    metadata = v.info or v.metadata or {},
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
        return tgiann:HasItem(src, item, count or 1) == true
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
        local tbl = stashes[stashId] or { weight = 1000000, slots = 50, label = 'Stash' }
        tgiann:ForceOpenInventory(src, 'stash', stashId, {
            maxWeight = tbl.weight,
            slots     = tbl.slots,
            label     = tbl.label,
        })
    end,

    ---@param src number
    ---@param targetSrc number
    ---@return boolean
    OpenPlayerInventory = function(src, targetSrc)
        assert(src, 'OpenPlayerInventory: src is required')
        assert(targetSrc, 'OpenPlayerInventory: targetSrc is required')
        tgiann:OpenInventoryById(src, targetSrc)
        return true
    end,

    ---@param item string
    ---@return table {name, label, weight, description}
    GetItemInfo = function(item)
        local items = tgiann:GetItemList()
        if not items or not items[item] then return {} end
        local data = items[item]
        return { name = data.name, label = data.label, weight = data.weight, description = data.description }
    end,

    ---@param item string
    ---@return string
    GetImagePath = function(item)
        item = olink._stripExt(item)
        local png = LoadResourceFile('inventory_images', ('images/%s.png'):format(item))
        if png then return ('nui://inventory_images/images/%s.png'):format(item) end
        local webp = LoadResourceFile('inventory_images', ('images/%s.webp'):format(item))
        if webp then return ('nui://inventory_images/images/%s.webp'):format(item) end
        return ''
    end,
})
