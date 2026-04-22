if not olink._guardImpl('Inventory', 'ox_inventory', 'ox_inventory') then return end
if not olink._hasOverride('Inventory') and GetResourceState('oxide-inventory') == 'started' then return end
if not olink._hasOverride('Inventory') and GetResourceState('qb-inventory') == 'started' then return end

local ox_inventory = exports.ox_inventory

local stashes = {}

olink._register('inventory', {
    ---@param src number
    ---@param item string
    ---@return number
    GetItemCount = function(src, item)
        return ox_inventory:GetItemCount(src, item, nil, false) or 0
    end,

    ---@param src number
    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(src, item, count)
        local total = ox_inventory:GetItemCount(src, item, nil, false) or 0
        return total >= (count or 1)
    end,

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
        for _, item in pairs(items) do
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

    ---@param item string
    ---@return table
    GetItemInfo = function(item)
        local data = ox_inventory:Items(item)
        if not data then return {} end
        return {
            name = data.name,
            label = data.label,
            weight = data.weight,
            description = data.description,
            stack = data.stack,
            image = ('nui://ox_inventory/web/images/%s'):format(
                (data.client and data.client.image) or ('%s.png'):format(item)),
        }
    end,

    ---@param src number
    ---@param item string
    ---@param slot number
    ---@param metadata table
    ---@return boolean
    SetMetadata = function(src, item, slot, metadata)
        ox_inventory:SetMetadata(src, slot, metadata)
        return true
    end,

    ---@param item string
    ---@return string
    GetImagePath = function(item)
        item = olink._stripExt(item)
        local file = LoadResourceFile('ox_inventory', ('web/images/%s.png'):format(item))
        if file then return ('nui://ox_inventory/web/images/%s.png'):format(item) end
        return 'https://avatars.githubusercontent.com/u/47620135'
    end,

    ---@return table All item definitions
    Items = function()
        return ox_inventory:Items() or {}
    end,

    ---@param src number
    ---@param item string
    ---@param count number|nil
    ---@return boolean
    CanCarryItem = function(src, item, count)
        return ox_inventory:CanCarryItem(src, item, count or 1) == true
    end,

    ---@param id string
    ---@return table[]
    GetStashItems = function(id)
        return ox_inventory:GetInventoryItems(tostring(id), false) or {}
    end,

    ---@param id string
    ---@param item string
    ---@param count number
    ---@return boolean
    RemoveStashItem = function(id, item, count)
        local success = ox_inventory:RemoveItem(tostring(id), item, count)
        return success == true
    end,

    ---@param id string
    ---@param _type string|nil unused
    ---@return boolean
    ClearStash = function(id, _type)
        ox_inventory:ClearInventory(tostring(id))
        return true
    end,

    ---@param identifier string plate or trunk identifier
    ---@param items table[]
    ---@return boolean
    AddTrunkItems = function(identifier, items)
        local trunkId = ('trunk_%s'):format(tostring(identifier))
        if not stashes[trunkId] then
            stashes[trunkId] = true
            ox_inventory:RegisterStash(trunkId, 'Vehicle Trunk', 50, 100000, nil)
        end
        Wait(100)
        for _, item in ipairs(items or {}) do
            ox_inventory:AddItem(trunkId, item.name, item.count or item.amount or 1, item.metadata)
        end
        return true
    end,

    ---@param oldPlate string
    ---@param newPlate string
    ---@return boolean
    UpdatePlate = function(oldPlate, newPlate)
        ox_inventory:UpdateVehicle(oldPlate, newPlate)
        if GetResourceState('jg-mechanic') == 'started' then
            exports['jg-mechanic']:vehiclePlateUpdated(oldPlate, newPlate)
        end
        return true
    end,

    ---@param id string
    ---@param items table[] { item, count, metadata }
    ---@return boolean
    AddStashItems = function(id, items)
        if type(items) ~= 'table' then return false end
        local success = false
        for _, v in pairs(items) do
            success = ox_inventory:AddItem(tostring(id), v.item, v.count or v.amount, v.metadata or v.info or {})
        end
        return success == true
    end,

    ---@param src number
    ---@param shopTitle string
    OpenShop = function(src, shopTitle)
        ox_inventory:openInventory(src, 'shop', { type = shopTitle })
    end,

    ---@param shopTitle string
    ---@param shopInventory table
    ---@param shopCoords table|nil
    ---@param shopGroups table|nil
    RegisterShop = function(shopTitle, shopInventory, shopCoords, shopGroups)
        ox_inventory:RegisterShop(shopTitle, { inventory = shopInventory })
    end,
})
