if not olink._guardImpl('Radial', 'ox_lib', 'ox_lib') then return end
if not olink._hasOverride('Radial') and GetResourceState('oxide-menu') == 'started' then return end

local nextId = 0
local function createUniqueId()
    nextId = nextId + 1
    return ('radial_%d'):format(nextId)
end

local ConvertMenu
local registeredMenus = {}

local function runItem(item, menuOnSelect, currentMenu, itemIndex)
    if item.disabled then return end

    if type(item.onSelect) == 'function' then
        item.onSelect(item.args, item, itemIndex, currentMenu)
    end

    if item.event then
        TriggerEvent(item.event, item.args, item)
    end

    if item.serverEvent then
        TriggerServerEvent(item.serverEvent, item.args, item)
    end

    if type(menuOnSelect) == 'function' then
        menuOnSelect(item, itemIndex, currentMenu)
    end
end

local function ConvertItems(menuId, items, menuOnSelect)
    local converted = {}

    for i, item in ipairs(items or {}) do
        local itemId = item.id or ('%s_%d'):format(menuId, i)
        local out = {
            id = itemId,
            label = item.label or item.title or itemId,
            icon = item.icon,
            iconColor = item.iconColor,
            disabled = item.disabled,
            keepOpen = item.disabled == true or item.keepOpen == true,
            args = item.args,
        }

        if item.disabled then
            out.keepOpen = true
        elseif item.submenu then
            local submenuId = ('%s_%s_submenu'):format(menuId, itemId)
            local submenu
            if item.submenu.items then
                submenu = ConvertMenu(item.submenu, item.submenu.id or submenuId, menuOnSelect)
            else
                submenu = ConvertMenu({
                    id = submenuId,
                    items = item.submenu,
                    onSelect = menuOnSelect,
                }, submenuId, menuOnSelect)
            end
            lib.registerRadial(submenu)
            out.menu = submenu.id
        elseif item.menu then
            out.menu = item.menu
        else
            out.onSelect = function(currentMenu, itemIndex)
                runItem(item, menuOnSelect, currentMenu, itemIndex)
            end
        end

        converted[i] = out
    end

    return converted
end

ConvertMenu = function(menu, fallbackId, fallbackOnSelect)
    local id = menu.id or fallbackId or createUniqueId()
    local menuOnSelect = type(menu.onSelect) == 'function' and menu.onSelect or fallbackOnSelect

    return {
        id = id,
        title = menu.title or menu.label or id,
        icon = menu.icon,
        items = ConvertItems(id, menu.items or {}, menuOnSelect),
    }
end

local function AddGlobalSubmenu(menu)
    if not menu or not menu.id then return false end

    lib.registerRadial({
        id = menu.id,
        items = menu.items,
    })

    lib.addRadialItem({
        id = menu.id,
        label = menu.title or menu.label or menu.id,
        icon = menu.icon or 'circle-dot',
        menu = menu.id,
    })

    registeredMenus[menu.id] = menu
    return true
end

local api = {}

api.GetResourceName = function()
    return 'ox_lib'
end

api.Register = function(menu)
    if type(menu) ~= 'table' or not menu.id then return false end
    local converted = ConvertMenu(menu, menu.id)
    registeredMenus[converted.id] = converted
    lib.registerRadial({
        id = converted.id,
        items = converted.items,
    })
    return true
end

api.Unregister = function(id)
    if not id then return false end
    registeredMenus[id] = nil
    lib.removeRadialItem(id)
    return true
end

api.Open = function(idOrData, _options)
    if type(idOrData) == 'table' then
        local converted = ConvertMenu(idOrData, idOrData.id)
        idOrData.id = converted.id
        return AddGlobalSubmenu(converted) and converted.id or false
    end

    if type(idOrData) == 'string' then
        local menu = registeredMenus[idOrData]
        return AddGlobalSubmenu(menu) and idOrData or false
    end

    return false
end

api.Close = function()
    lib.hideRadial()
    return true
end

api.IsOpen = function()
    return lib.getCurrentRadialId() ~= nil
end

api.GetCurrentId = function()
    return lib.getCurrentRadialId()
end

api.AddItem = function(items)
    if type(items) ~= 'table' then return false end

    local isArray = items[1] ~= nil
    local converted = ConvertItems('global', isArray and items or { items }, nil)
    lib.addRadialItem(isArray and converted or converted[1])
    return true
end

api.RemoveItem = function(id)
    if not id then return false end
    lib.removeRadialItem(id)
    return true
end

api.ClearItems = function()
    lib.clearRadialItems()
    return true
end

api.Disable = function(state)
    lib.disableRadial(state)
    return true
end

api.Refresh = function()
    return false
end

api.RegisterRadial = api.Register
api.AddRadialItem = api.AddItem
api.RemoveRadialItem = api.RemoveItem
api.ClearRadialItems = api.ClearItems
api.HideRadial = api.Close
api.DisableRadial = api.Disable
api.GetCurrentRadialId = api.GetCurrentId

olink._register('radial', api, 'ox_lib')
