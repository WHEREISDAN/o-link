if GetResourceState('esx_society') ~= 'started' then return end

RegisterNetEvent('o-link:client:OpenBossMenu', function(jobName, jobType)
    if source ~= 65535 then return end
    local ESX = exports["es_extended"]:getSharedObject()
    TriggerEvent('esx_society:openBossMenu', jobName, function(menu)
        ESX.CloseContext()
    end, { wash = false })
end)

olink._register('bossmenu', {
    ---@return string
    GetResourceName = function()
        return 'esx_society'
    end,
})
