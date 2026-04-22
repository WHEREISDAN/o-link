if not olink._guardImpl('Dispatch', 'emergencydispatch', 'emergencydispatch') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'emergencydispatch'
    end,
})

-- Client fires emergencydispatch's own net event directly (matches
-- community_bridge). No server relay here — that would zero out `source`
-- when emergencydispatch's handler reads it.
