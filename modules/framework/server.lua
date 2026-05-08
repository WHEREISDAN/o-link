-- Cross-framework helpers registered on top of the active framework adapter.
-- Loads after per-framework files due to alphabetical glob order.

if olink._frameworkHelpersLoaded then return end
olink._frameworkHelpersLoaded = true

olink._register('framework', {
    ---Passthrough to the active inventory's item definitions.
    ---@return table
    ItemList = function()
        if olink.inventory and olink.inventory.Items then
            return olink.inventory.Items() or {}
        end
        return {}
    end,

    ---Read a framework-specific status column. Returns nil when the active
    ---framework has no meaningful status column for the given name.
    ---@param src number
    ---@param column string
    ---@return any|nil
    GetStatus = function(src, column)
        if not src or not column then return nil end
        if olink.needs and olink.needs.GetNeed then
            if column == 'hunger' or column == 'thirst' or column == 'stress' then
                return olink.needs.GetNeed(src, column)
            end
        end
        return nil
    end,
})
