if not olink._guardImpl('Dispatch', 'emergencydispatch', 'emergencydispatch') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end

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
        -- Match community_bridge: fire emergencydispatch's own net event
        -- directly from the client so `source` is the calling player on the
        -- server side. Going through an o-link server relay would zero out
        -- the source, which emergencydispatch may depend on.
        TriggerServerEvent('emergencydispatch:emergencycall:new', job, message, coords, true)
    end,
})
