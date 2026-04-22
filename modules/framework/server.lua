-- Cross-framework helpers registered on top of the active framework adapter.
-- Loads after per-framework files due to alphabetical glob order.

if olink._frameworkHelpersLoaded then return end
olink._frameworkHelpersLoaded = true

olink._register('framework', {
    ---Community_bridge-style passthrough that exposes the active inventory's
    ---item definitions at the framework level. Mirrors `Framework.ItemList()`.
    ---@return table
    ItemList = function()
        if olink.inventory and olink.inventory.Items then
            return olink.inventory.Items() or {}
        end
        return {}
    end,

    ---Read a framework-specific status column. Most frameworks don't expose a
    ---generic status API — this is here for community_bridge signature parity.
    ---Returns nil when the active framework has no meaningful status column for
    ---the given name; callers should check for nil.
    ---@param src number
    ---@param column string
    ---@return any|nil
    GetStatus = function(src, column)
        if not src or not column then return nil end
        -- Needs module covers hunger/thirst/stress; delegate when possible.
        if olink.needs and olink.needs.GetNeed then
            if column == 'hunger' or column == 'thirst' or column == 'stress' then
                return olink.needs.GetNeed(src, column)
            end
        end
        -- No generic fallback — return nil so callers know to skip.
        return nil
    end,
})
