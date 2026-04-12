if GetResourceState('emergencydispatch') == 'missing' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'emergencydispatch'
    end,

    ---@param data table
    SendAlert = function(data)
        local ped = PlayerPedId()
        local job = data.job or (data.jobs and data.jobs[1]) or 'police'
        local message = data.message or 'An Alert Has Been Made'
        local coords = data.coords or GetEntityCoords(ped)
        TriggerServerEvent('o-link:dispatch:emergencydispatch:sendAlert', {
            job = job,
            message = message,
            coords = coords,
        })
    end,
})
