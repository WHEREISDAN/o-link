if not olink._guardImpl('Dispatch', 'piotreq_gpt', 'piotreq_gpt') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'piotreq_gpt'
    end,

    ---@param data table
    SendAlert = function(data)
        if not data then return end
        TriggerServerEvent('o-link:dispatch:piotreq_gpt:sendAlert', data)
    end,
})
