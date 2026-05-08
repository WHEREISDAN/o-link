-- Alias: `OpenMenu(id, data, useQBinput)` delegates to `Open(data)` with id moved into data.id.

if not olink.menu then return end
if olink._menuAliasesLoaded then return end
olink._menuAliasesLoaded = true

olink._register('menu', {
    ---@param id string
    ---@param data table
    ---@param useQBinput boolean|nil
    ---@return string|nil
    OpenMenu = function(id, data, useQBinput)
        if not olink.menu or not olink.menu.Open then return nil end
        data = data or {}
        data.id = id
        return olink.menu.Open(data, useQBinput)
    end,
})
