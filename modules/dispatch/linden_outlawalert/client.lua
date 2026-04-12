if GetResourceState('linden_outlawalert') ~= 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'linden_outlawalert'
    end,

    ---@param data table
    SendAlert = function(data)
        local ped = PlayerPedId()
        TriggerServerEvent('wf-alerts:svNotify', {
            dispatchData = {
                displayCode = data.code or '211',
                description = data.message or 'Alert',
                isImportant = 0,
                recipientList = data.jobs or { 'police' },
                length = data.time or '10000',
                infoM = data.icon or 'fas fa-question',
                info = data.message or 'Alert',
            },
            caller = 'Anonymous',
            coords = data.coords or GetEntityCoords(ped),
        })
    end,
})
