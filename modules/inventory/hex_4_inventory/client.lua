if not olink._guardImpl('Inventory', 'hex_4_inventory', 'hex_4_inventory') then return end
if not olink._hasOverride('Inventory') and GetResourceState('oxide-inventory') == 'started' then return end

-- hex_4_inventory renders the framework's own item store, so client reads go
-- through ESX/QB player data rather than hex exports. ESX keeps weapons in the
-- ped loadout instead of the item list, mirroring hex's own client/framework.
local RESOURCE = 'hex_4_inventory'
local ICON_DIR = 'dist/img/icons'
local FALLBACK_ICON = 'https://avatars.githubusercontent.com/u/47620135'

local ESX = GetResourceState('es_extended') == 'started' and exports['es_extended']:getSharedObject() or nil
local QBCore = not ESX and GetResourceState('qb-core') == 'started' and exports['qb-core']:GetCoreObject() or nil
local iconCache = {}

---@return table[]
local function rawItems()
    if ESX then
        local data = ESX.GetPlayerData()
        return (data and data.inventory) or {}
    end
    if QBCore then
        local data = QBCore.Functions.GetPlayerData()
        return (data and data.items) or {}
    end
    return {}
end

---@return table[] ESX's weapon list, or empty when unavailable.
local function weaponList()
    if not ESX or ESX.GetWeaponList == nil then return {} end
    local ok, list = pcall(ESX.GetWeaponList)
    return (ok and type(list) == 'table') and list or {}
end

---@param item string
---@return boolean
local function isWeaponName(item)
    return type(item) == 'string' and item:lower():match('^weapon_[%w_]+$') ~= nil
end

---Weapons the local ped is carrying, keyed as lowercase item names.
---@return table[]
local function carriedWeapons()
    local ped = PlayerPedId()
    if not ped or ped == 0 then return {} end

    local carried = {}
    for _, data in pairs(weaponList()) do
        local name = type(data) == 'table' and data.name or nil
        if type(name) == 'string' and name:upper() ~= 'WEAPON_UNARMED' then
            local hash = joaat(name:upper())
            if HasPedGotWeapon(ped, hash, false) then
                carried[#carried + 1] = {
                    name = name:lower(),
                    label = data.label or name,
                    ammo = GetAmmoInPedWeapon(ped, hash),
                    tintIndex = GetPedWeaponTintIndex(ped, hash),
                }
            end
        end
    end
    return carried
end

olink._register('inventory', {
    ---@return string
    GetResourceName = function()
        return RESOURCE
    end,

    ---@return table[] SlotData[]
    GetPlayerInventory = function()
        local result = {}
        for _, v in pairs(rawItems()) do
            local count = v.count or v.amount or 0
            if v.name and count > 0 then
                result[#result + 1] = {
                    name     = v.name,
                    label    = v.label or v.name,
                    count    = count,
                    slot     = v.slot or 0,
                    metadata = v.info or v.metadata or {},
                    weight   = v.weight,
                }
            end
        end

        for _, weapon in ipairs(carriedWeapons()) do
            result[#result + 1] = {
                name     = weapon.name,
                label    = weapon.label,
                count    = 1,
                slot     = #result + 1,
                metadata = { ammo = weapon.ammo, tintIndex = weapon.tintIndex },
                weight   = 0,
                type     = 'weapon',
            }
        end
        return result
    end,

    ---@param item string
    ---@return number
    GetItemCount = function(item)
        if ESX and isWeaponName(item) then
            local ped = PlayerPedId()
            return (ped ~= 0 and HasPedGotWeapon(ped, joaat(item:upper()), false)) and 1 or 0
        end

        local total = 0
        for _, v in pairs(rawItems()) do
            if v.name == item then
                total = total + (v.count or v.amount or 0)
            end
        end
        return total
    end,

    ---@param item string
    ---@param count number|nil
    ---@return boolean
    HasItem = function(item, count)
        return olink.inventory.GetItemCount(item) >= (count or 1)
    end,

    ---@param item string
    ---@return table {name, label, weight, description}
    GetItemInfo = function(item)
        local data = QBCore and QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[item]
        if data then
            return { name = data.name, label = data.label, weight = data.weight, description = data.description }
        end
        for _, v in pairs(rawItems()) do
            if v.name == item then
                return { name = v.name, label = v.label or v.name, weight = v.weight }
            end
        end
        if isWeaponName(item) then
            for _, weapon in pairs(weaponList()) do
                if type(weapon) == 'table' and type(weapon.name) == 'string'
                    and weapon.name:lower() == item:lower() then
                    return { name = item, label = weapon.label or weapon.name, weight = 0, type = 'weapon' }
                end
            end
        end
        return {}
    end,

    ---@param item string
    ---@return string
    GetImagePath = function(item)
        item = olink._stripExt(item)
        local cached = iconCache[item]
        if cached then return cached end

        -- Hex ships weapon icons uppercase (WEAPON_PISTOL.png) and item icons
        -- lowercase. Filenames are case-sensitive on Linux hosts, so try the
        -- name as given plus both casings before giving up.
        local seen, path = {}, nil
        for _, name in ipairs({ item, item:upper(), item:lower() }) do
            if not seen[name] then
                seen[name] = true
                local rel = ('%s/%s.png'):format(ICON_DIR, name)
                if LoadResourceFile(RESOURCE, rel) then
                    path = ('nui://%s/%s'):format(RESOURCE, rel)
                    break
                end
            end
        end

        path = path or FALLBACK_ICON
        iconCache[item] = path
        return path
    end,

    ---@return table All item definitions
    Items = function()
        if QBCore then return (QBCore.Shared and QBCore.Shared.Items) or {} end
        if not ESX then return {} end

        -- ESX's client inventory lists every defined item, including ones the
        -- player holds none of, so it doubles as the item catalogue. Weapons
        -- are absent from it and come from the shared weapon list instead.
        local items = {}
        for _, v in pairs(rawItems()) do
            if v.name then
                items[v.name] = { name = v.name, label = v.label or v.name, weight = v.weight or 0 }
            end
        end

        for _, weapon in pairs(weaponList()) do
            local name = type(weapon) == 'table' and weapon.name or nil
            if type(name) == 'string' and name:upper() ~= 'WEAPON_UNARMED' then
                local key = name:lower()
                if not items[key] then
                    items[key] = { name = key, label = weapon.label or name, weight = 0, type = 'weapon' }
                end
            end
        end
        return items
    end,
})
