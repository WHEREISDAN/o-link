if GetResourceState('qb-management') == 'missing' then return end
if GetResourceState('qbx_management') == 'started' then return end

olink._register('bossmenu', {
    ---@return string
    GetResourceName = function()
        return 'qb-management'
    end,

    ---@param src number
    ---@param jobName string
    ---@param jobType string
    OpenBossMenu = function(src, jobName, jobType)
        TriggerClientEvent("qb-bossmenu:client:OpenMenu", src)
    end,
})
