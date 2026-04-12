if GetResourceState('esx_society') == 'missing' then return end

local registeredSocieties = {}

olink._register('bossmenu', {
    ---@return string
    GetResourceName = function()
        return 'esx_society'
    end,

    ---@param src number
    ---@param jobName string
    ---@param jobType string
    OpenBossMenu = function(src, jobName, jobType)
        if not registeredSocieties[jobName] then
            exports["esx_society"]:registerSociety(jobName, jobName, 'society_' .. jobName, 'society_' .. jobName, 'society_' .. jobName, { type = 'private' })
            registeredSocieties[jobName] = true
        end
        TriggerClientEvent("o-link:client:OpenBossMenu", src, jobName, jobType)
    end,
})
