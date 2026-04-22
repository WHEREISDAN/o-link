-- Community_bridge naming alias for menu.
-- cb exposes `Menu.OpenMenu(id, data, useQBinput)` (id as first argument).
-- o-link adapters register `Open(data, useQb)` where the id lives inside
-- `data.id`. This shim adds cb's signature, delegating to the adapter.

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
