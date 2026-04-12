if GetResourceState('lation_ui') == 'missing' then return end
if GetResourceState('oxide-menu') == 'started' then return end
if GetResourceState('qb-menu') == 'started' then return end
if GetResourceState('wasabi_uikit') == 'started' then return end

local menus = {}

local function runCheckForImageIcon(icon)
    local iconStr = tostring(icon):lower()
    if iconStr:match('^https?://') or iconStr:match('^nui://') or iconStr:match('^file://') then
        return true
    end
    local extensions = { '.png', '.jpg', '.jpeg', '.gif', '.bmp', '.svg', '.webp', '.ico' }
    for _, ext in pairs(extensions) do
        if iconStr:match(ext .. '$') then
            return true
        end
    end
    return false
end

---@param id string
---@param menu table
---@return table
local function QBToLationMenu(id, menu)
    local lationMenu = {
        id = id,
        title = '',
        canClose = true,
        options = {},
    }
    for i, v in pairs(menu) do
        if v.isMenuHeader then
            if lationMenu.title == '' then
                lationMenu.title = v.header
            end
        else
            local option = {
                title = v.header,
                description = v.txt,
                icon = v.icon,
                args = v.params and v.params.args,
                onSelect = function(selected, secondary, args)
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
            table.insert(lationMenu.options, option)
        end
    end
    return lationMenu
end

---@param data table
---@return table
local function OxToLationMenu(data)
    local repack = {
        id = data.id,
        title = data.title or '',
        canClose = data.canClose ~= false,
        options = {},
    }
    for k, v in pairs(data.options) do
        if v.iconColor then
            if v.icon and runCheckForImageIcon(v.icon) then
                v.iconColor = nil
            end
        end
        table.insert(repack.options, v)
    end
    return repack
end

local nextId = 0
local function createUniqueId()
    nextId = nextId + 1
    return ('menu_%d'):format(nextId)
end

olink._register('menu', {
    ---@return string
    GetResourceName = function()
        return 'lation_ui'
    end,

    ---@param data table
    ---@param useQb boolean|nil
    ---@return string
    Open = function(data, useQb)
        local id = data.id or createUniqueId()
        local menuData
        if useQb then
            menuData = QBToLationMenu(id, data)
        else
            menuData = OxToLationMenu(data)
        end
        menus[id] = menuData
        data.id = id
        exports.lation_ui:registerMenu(menuData)
        exports.lation_ui:showMenu(id)
        return id
    end,
})
