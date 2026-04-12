if GetResourceState('emergencydispatch') ~= 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'emergencydispatch'
    end,
})

RegisterNetEvent('o-link:dispatch:emergencydispatch:sendAlert', function(data)
    local job = data.job or (data.jobs and data.jobs[1]) or 'police'
    local message = data.message or 'An Alert Has Been Made'
    local coords = data.coords or vector3(0, 0, 0)
    TriggerEvent('emergencydispatch:emergencycall:new', job, message, coords, true)
end)
