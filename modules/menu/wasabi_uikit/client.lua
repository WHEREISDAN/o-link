if GetResourceState('wasabi_uikit') == 'missing' then return end
if GetResourceState('oxide-menu') == 'started' then return end
if GetResourceState('qb-menu') == 'started' then return end

local menus = {}

---@param id string
---@param menu table
---@return table
local function QBToWasabiMenu(id, menu)
    local wasabiMenu = {
        id = id,
        title = '',
        canClose = true,
        options = {},
    }
    for i, v in pairs(menu) do
        if v.isMenuHeader then
            if wasabiMenu.title == '' then
                wasabiMenu.title = v.header
            end
        else
            local option = {
                title = v.header,
                description = v.txt,
                icon = v.icon,
                args = v.params and v.params.args,
                onSelect = v.action or function(selected, secondary, args)
                    local params = v.params
                    if not params then return end
                    local event = params.event
                    local isServer = params.isServer
                    if not event then return end
                    if isServer then
                        return TriggerServerEvent(event, args)
                    end
                    return TriggerEvent(event, args)
                end,
            }
            table.insert(wasabiMenu.options, option)
        end
    end
    return wasabiMenu
end

local nextId = 0
local function createUniqueId()
    nextId = nextId + 1
    return ('menu_%d'):format(nextId)
end

olink._register('menu', {
    ---@return string
    GetResourceName = function()
        return 'wasabi_uikit'
    end,

    ---@param data table
    ---@param useQb boolean|nil
    ---@return string
    Open = function(data, useQb)
        local id = data.id or createUniqueId()
        local menuData
        if useQb then
            menuData = QBToWasabiMenu(id, data)
        else
            menuData = data
        end
        menus[id] = menuData
        data.id = id
        exports.wasabi_uikit:RegisterContextMenu(menuData)
        exports.wasabi_uikit:OpenContextMenu(id)
        return id
    end,
})
