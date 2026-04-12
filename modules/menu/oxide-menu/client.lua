if GetResourceState('oxide-menu') ~= 'started' then return end

-- Store callbacks locally since functions can't cross the export boundary to oxide-menu
local menuCallbacks = {}
local menus = {}
local BRIDGE_SELECT_EVENT = 'o-link:oxide-menu:select'

---@param menuId string
---@param options table
---@return table
local function ConvertOptions(menuId, options)
    if not options then return {} end
    menuCallbacks[menuId] = {}
    local items = {}
    for i, v in ipairs(options) do
        local itemId = ('%s_%d'):format(menuId, i)
        if v.onSelect then
            menuCallbacks[menuId][itemId] = v.onSelect
        end
        items[i] = {
            id = itemId,
            title = v.title,
            description = v.description,
            icon = v.icon,
            iconColor = v.iconColor,
            event = v.onSelect and BRIDGE_SELECT_EVENT or v.event,
            serverEvent = v.serverEvent,
            args = v.args,
            disabled = v.disabled,
            metadata = v.metadata,
            keepOpen = v.keepOpen,
        }
    end
    return items
end

---@param id string
---@param menu table
---@return table
local function QBToOxideMenu(id, menu)
    menuCallbacks[id] = {}
    local oxideMenu = {
        id = id,
        title = '',
        items = {},
    }
    local idx = 0
    for _, v in pairs(menu) do
        if v.isMenuHeader then
            if oxideMenu.title == '' then
                oxideMenu.title = v.header
            end
        else
            idx = idx + 1
            local itemId = ('%s_%d'):format(id, idx)
            local cb = v.action or function(args)
                local params = v.params
                if not params then return end
                local event = params.event
                local isServer = params.isServer
                if not event then return end
                if isServer then
                    return TriggerServerEvent(event, args)
                end
                return TriggerEvent(event, args)
            end
            menuCallbacks[id][itemId] = cb
            oxideMenu.items[#oxideMenu.items + 1] = {
                id = itemId,
                title = v.header,
                description = v.txt,
                icon = v.icon,
                args = v.params and v.params.args,
                event = BRIDGE_SELECT_EVENT,
            }
        end
    end
    return oxideMenu
end

-- Handle item selection via event (functions can't cross export boundaries)
AddEventHandler(BRIDGE_SELECT_EVENT, function(args, item)
    if not item or not item.id then return end
    for _, callbacks in pairs(menuCallbacks) do
        local cb = callbacks[item.id]
        if cb then
            cb(args)
            return
        end
    end
end)

-- Handle MenuCallback for QB-style onSelect
RegisterNetEvent('o-link:client:MenuCallback', function(_args)
    local id = _args.id
    local onSelect = _args.onSelect
    local args = _args.args
    menus[id] = nil
    onSelect(args)
end)

local nextId = 0
local function createUniqueId()
    nextId = nextId + 1
    return ('menu_%d'):format(nextId)
end

olink._register('menu', {
    ---@return string
    GetResourceName = function()
        return 'oxide-menu'
    end,

    ---@param data table
    ---@param useQb boolean|nil
    ---@return string
    Open = function(data, useQb)
        local id = data.id or createUniqueId()
        local menuData
        if useQb then
            menuData = QBToOxideMenu(id, data)
        else
            menuData = {
                id = id,
                title = data.title or '',
                subtitle = data.subtitle,
                items = ConvertOptions(id, data.options),
                onClose = data.onClose,
            }
        end
        menus[id] = menuData
        data.id = id
        exports['oxide-menu']:Open(menuData)
        return id
    end,
})
