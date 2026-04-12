if GetResourceState('qb-menu') == 'missing' then return end
if GetResourceState('oxide-menu') == 'started' then return end

local menus = {}

---@param id string
---@param menu table
---@return table
local function OxToQBMenu(id, menu)
    local qbMenu = {
        {
            header = menu.title,
            isMenuHeader = true,
        }
    }
    for i, v in pairs(menu.options) do
        local button = {
            header = v.title,
            txt = v.description,
            icon = v.icon,
            disabled = v.disabled,
        }
        if v.onSelect then
            button.params = {
                event = 'o-link:client:MenuCallback',
                args = { id = id, selected = i, args = v.args, onSelect = v.onSelect },
            }
        else
            button.params = {}
        end
        table.insert(qbMenu, button)
    end
    return qbMenu
end

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
        return 'qb-menu'
    end,

    ---@param data table
    ---@param useQb boolean|nil
    ---@return string
    Open = function(data, useQb)
        local id = data.id or createUniqueId()
        local menuData
        if useQb then
            menuData = data
        else
            menuData = OxToQBMenu(id, data)
        end
        menus[id] = menuData
        data.id = id
        exports['qb-menu']:openMenu(menuData)
        return id
    end,
})
