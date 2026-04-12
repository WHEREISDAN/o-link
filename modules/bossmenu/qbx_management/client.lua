if GetResourceState('qbx_management') == 'missing' then return end

RegisterNetEvent('o-link:client:OpenBossMenu', function(jobName, jobType)
    if source ~= 65535 then return end
    exports.qbx_management:OpenBossMenu(jobType)
end)

olink._register('bossmenu', {
    ---@return string
    GetResourceName = function()
        return 'qbx_management'
    end,
})
