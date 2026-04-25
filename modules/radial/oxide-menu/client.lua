if not olink._guardImpl('Radial', 'oxide-menu', 'oxide-menu') then return end

local radialCallbacks = {}
local closeCallbacks = {}
local BRIDGE_SELECT_EVENT = 'o-link:oxide-menu:radial:select'
local BRIDGE_CLOSE_EVENT = 'o-link:oxide-menu:radial:close'

local nextId = 0
local function createUniqueId()
    nextId = nextId + 1
    return ('radial_%d'):format(nextId)
end

local function callbackKey(menuId, itemId)
    return ('%s:%s'):format(menuId, itemId)
end

local ConvertMenu

local function ConvertItems(menuId, items, menuOnSelect)
    local converted = {}

    for i, item in ipairs(items or {}) do
        local itemId = item.id or ('%s_%d'):format(menuId, i)
        local out = {
            id = itemId,
            label = item.label or item.title,
            title = item.title or item.label,
            icon = item.icon,
            iconColor = item.iconColor,
            disabled = item.disabled,
            keepOpen = item.keepOpen,
        }

        if item.submenu then
            local submenuId = ('%s_%s_submenu'):format(menuId, itemId)
            if item.submenu.items then
                out.submenu = ConvertMenu(item.submenu, item.submenu.id or submenuId, menuOnSelect)
            else
                out.submenu = ConvertMenu({
                    id = submenuId,
                    title = item.label or item.title,
                    items = item.submenu,
                    onSelect = menuOnSelect,
                }, submenuId, menuOnSelect)
            end
        elseif item.menu then
            out.menu = item.menu
        else
            local needsBridge = type(item.onSelect) == 'function'
                or type(menuOnSelect) == 'function'
                or item.event ~= nil
                or item.serverEvent ~= nil

            if needsBridge then
                local key = callbackKey(menuId, itemId)
                radialCallbacks[key] = {
                    menuId = menuId,
                    itemId = itemId,
                    index = i,
                    item = item,
                    args = item.args,
                    onSelect = item.onSelect,
                    event = item.event,
                    serverEvent = item.serverEvent,
                    menuOnSelect = menuOnSelect,
                }
                out.event = BRIDGE_SELECT_EVENT
                out.args = {
                    __olinkRadialKey = key,
                    args = item.args,
                }
            else
                out.event = item.event
                out.serverEvent = item.serverEvent
                out.args = item.args
            end
        end

        converted[i] = out
    end

    return converted
end

ConvertMenu = function(menu, fallbackId, fallbackOnSelect)
    local id = menu.id or fallbackId or createUniqueId()
    local menuOnSelect = type(menu.onSelect) == 'function' and menu.onSelect or fallbackOnSelect

    if type(menu.onClose) == 'function' then
        closeCallbacks[id] = menu.onClose
    end

    return {
        id = id,
        title = menu.title or menu.label or '',
        items = ConvertItems(id, menu.items or {}, menuOnSelect),
        onClose = closeCallbacks[id] and function(menuId)
            TriggerEvent(BRIDGE_CLOSE_EVENT, menuId or id)
        end or nil,
    }
end

AddEventHandler(BRIDGE_SELECT_EVENT, function(payload)
    local key = type(payload) == 'table' and payload.__olinkRadialKey or nil
    local data = key and radialCallbacks[key] or nil
    if not data then return end

    local args = type(payload) == 'table' and payload.args or data.args

    if type(data.onSelect) == 'function' then
        local success, err = pcall(data.onSelect, args, data.item, data.index, data.menuId)
        if not success then
            print('[o-link] radial item callback failed: ' .. tostring(err))
        end
    end

    if data.event then
        TriggerEvent(data.event, args, data.item)
    end

    if data.serverEvent then
        TriggerServerEvent(data.serverEvent, args, data.item)
    end

    if type(data.menuOnSelect) == 'function' then
        local success, err = pcall(data.menuOnSelect, data.item, data.index, data.menuId)
        if not success then
            print('[o-link] radial menu callback failed: ' .. tostring(err))
        end
    end
end)

AddEventHandler(BRIDGE_CLOSE_EVENT, function(menuId)
    local cb = closeCallbacks[menuId]
    if not cb then return end

    local success, err = pcall(cb, menuId)
    if not success then
        print('[o-link] radial close callback failed: ' .. tostring(err))
    end
end)

local api = {}

api.GetResourceName = function()
    return 'oxide-menu'
end

api.Register = function(menu)
    if type(menu) ~= 'table' then return false end
    local converted = ConvertMenu(menu, menu.id)
    return exports['oxide-menu']:RegisterRadial(converted) == true
end

api.Unregister = function(id)
    if not id then return false end
    closeCallbacks[id] = nil
    return exports['oxide-menu']:UnregisterRadial(id) == true
end

api.Open = function(idOrData, options)
    if type(idOrData) == 'table' then
        local converted = ConvertMenu(idOrData, idOrData.id)
        idOrData.id = converted.id
        return exports['oxide-menu']:OpenRadial(converted, options) or false
    end

    return exports['oxide-menu']:OpenRadial(idOrData, options) or false
end

api.Close = function()
    return exports['oxide-menu']:CloseRadial() == true
end

api.IsOpen = function()
    return exports['oxide-menu']:IsRadialOpen() == true
end

api.GetCurrentId = function()
    return exports['oxide-menu']:GetCurrentRadialId()
end

api.AddItem = function(items)
    if type(items) ~= 'table' then return false end

    local isArray = items[1] ~= nil
    local converted = ConvertItems('global', isArray and items or { items }, nil)

    if isArray then
        return exports['oxide-menu']:AddRadialItem(converted) == true
    end

    return exports['oxide-menu']:AddRadialItem(converted[1]) == true
end

api.RemoveItem = function(id)
    return exports['oxide-menu']:RemoveRadialItem(id) == true
end

api.ClearItems = function()
    return exports['oxide-menu']:ClearRadialItems() == true
end

api.Disable = function(state)
    return exports['oxide-menu']:DisableRadial(state) == true
end

api.Refresh = function()
    return exports['oxide-menu']:RefreshRadial() == true
end

api.RegisterRadial = api.Register
api.AddRadialItem = api.AddItem
api.RemoveRadialItem = api.RemoveItem
api.ClearRadialItems = api.ClearItems
api.HideRadial = api.Close
api.DisableRadial = api.Disable
api.GetCurrentRadialId = api.GetCurrentId

olink._register('radial', api, 'oxide-menu')
