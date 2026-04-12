if GetResourceState('qbx_management') ~= 'started' then return end

olink._register('bossmenu', {
    ---@return string
    GetResourceName = function()
        return 'qbx_management'
    end,

    ---@param src number
    ---@param jobName string
    ---@param jobType string
    OpenBossMenu = function(src, jobName, jobType)
        TriggerClientEvent("o-link:client:OpenBossMenu", src, jobName, jobType)
    end,
})
