if GetResourceState('qb-management') == 'missing' then return end
if GetResourceState('qbx_management') == 'started' then return end

olink._register('bossmenu', {
    ---@return string
    GetResourceName = function()
        return 'qb-management'
    end,
})
