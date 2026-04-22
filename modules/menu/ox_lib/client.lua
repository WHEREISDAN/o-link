if not olink._guardImpl('Menu', 'ox_lib', 'ox_lib') then return end
if not olink._hasOverride('Menu') and GetResourceState('oxide-menu') == 'started' then return end
if not olink._hasOverride('Menu') and GetResourceState('qb-menu') == 'started' then return end
if not olink._hasOverride('Menu') and GetResourceState('wasabi_uikit') == 'started' then return end
if not olink._hasOverride('Menu') and GetResourceState('lation_ui') == 'started' then return end

local menus = {}

---@param id string
---@param menu table
---@return table
local function QBToOxMenu(id, menu)
    local oxMenu = {
        id = id,
        title = '',
        canClose = true,
        options = {},
    }
    for i, v in pairs(menu) do
        if v.isMenuHeader then
            if oxMenu.title == '' then
                oxMenu.title = v.header
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
            table.insert(oxMenu.options, option)
        end
    end
    return oxMenu
end

local nextId = 0
local function createUniqueId()
    nextId = nextId + 1
    return ('menu_%d'):format(nextId)
end

olink._register('menu', {
    ---@return string
    GetResourceName = function()
        return 'ox_lib'
    end,

    ---@param data table
    ---@param useQb boolean|nil
    ---@return string
    Open = function(data, useQb)
        local id = data.id or createUniqueId()
        local menuData
        if useQb then
            menuData = QBToOxMenu(id, data)
        else
            menuData = data
        end
        menus[id] = menuData
        data.id = id
        lib.registerContext(menuData)
        lib.showContext(id)
        return id
    end,
})
