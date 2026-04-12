if GetResourceState('piotreq_gpt') == 'missing' then return end

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
