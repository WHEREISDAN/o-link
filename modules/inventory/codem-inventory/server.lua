if GetResourceState('oxide-inventory') == 'started' then return end
if GetResourceState('codem-inventory') == 'missing' then return end

local codem = exports['codem-inventory']
local QBCore = exports['qb-core']:GetCoreObject()
local stashes = {}

olink._register('inventory', {
    ---@param src number
    ---@param item string
    ---@return number
    GetItemCount = function(src, item)
        local identifier = olink.character.GetIdentifier(src)
        if not identifier then return 0 end
        local playerItems = codem:GetInventory(identifier, src)
        local total = 0
        for _, v in pairs(playerItems or {}) do
            if v.name == item then
                total = total + (v.amount or v.count or 0)
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
        local success = codem:AddItem(src, item, count, slot, metadata)
        return success == true
    end,

    ---@param src number
    ---@param item string
    ---@param count number
    ---@param slot number|nil
    ---@param metadata table|nil
    ---@return boolean
    RemoveItem = function(src, item, count, slot, metadata)
        local success = codem:RemoveItem(src, item, count, slot)
        return success == true
    end,

    ---@param src number
    ---@param slot number
    ---@return table|nil SlotData
    GetItemBySlot = function(src, slot)
        local data = codem:GetItemBySlot(src, slot)
        if not data then return nil end
        return {
            name     = data.name,
            label    = data.label or data.name,
            count    = data.amount or data.count,
            slot     = data.slot,
            weight   = data.weight,
            metadata = data.info or data.metadata or {},
        }
    end,

    ---@param src number
    ---@return table[] SlotData[]
    GetPlayerInventory = function(src)
        local identifier = olink.character.GetIdentifier(src)
        local playerItems = codem:GetInventory(identifier, src)
        local result = {}
        for _, v in pairs(playerItems or {}) do
            result[#result + 1] = {
                name     = v.name,
                label    = v.label,
                count    = v.amount or v.count,
                slot     = v.slot,
                metadata = v.info or v.metadata or {},
            }
        end
        return result
    end,

    ---@param src number
    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(src, item, count)
        return codem:HasItem(src, item, count or 1) == true
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
        stashes[id] = { label = label, slots = slots, weight = weight }
        return true
    end,

    ---@param src number
    ---@param stashId string
    OpenStash = function(src, stashId)
        stashId = tostring(stashId)
        local tbl = stashes[stashId] or {}
        codem:UpdateStash(stashId, {})
        TriggerClientEvent('codem-inventory:client:openStash', src, stashId)
    end,

    ---@param src number
    ---@param targetSrc number
    ---@return boolean
    OpenPlayerInventory = function(src, targetSrc)
        assert(src, 'OpenPlayerInventory: src is required')
        assert(targetSrc, 'OpenPlayerInventory: targetSrc is required')
        codem:OpenInventory(src, targetSrc)
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
        local file = LoadResourceFile('codem-inventory', ('html/itemimages/%s.png'):format(item))
        if file then return ('nui://codem-inventory/html/itemimages/%s.png'):format(item) end
        return ''
    end,
})
