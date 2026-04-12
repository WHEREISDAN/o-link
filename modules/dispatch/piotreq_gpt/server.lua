if GetResourceState('piotreq_gpt') ~= 'started' then return end

local function sendAlert(src, alertData)
    exports['piotreq_gpt']:SendAlert(src, {
        title = alertData.message or 'No message provided',
        code = alertData.code or '10-80',
        icon = alertData.icon or 'fa-solid fa-question',
        info = {
            { icon = 'fa-solid fa-road', isStreet = true },
            { icon = alertData.icon or 'fa-solid fa-question', data = alertData.message or 'No additional info' },
        },
        blip = {
            scale = alertData.blipData and alertData.blipData.scale or 1.0,
            sprite = alertData.blipData and alertData.blipData.sprite or 161,
            category = 1,
            color = alertData.blipData and alertData.blipData.color or 84,
            hidden = false,
            priority = alertData.priority or 5,
            short = true,
            alpha = 200,
            name = alertData.message or 'Dispatch Alert',
        },
        type = 'normal',
        canAnswer = false,
        maxOfficers = 6,
        time = 10,
        notifyTime = 8000,
    })
end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'piotreq_gpt'
    end,

    ---@param src number
    ---@param alertData table
    SendAlert = sendAlert,
})

RegisterNetEvent('o-link:dispatch:piotreq_gpt:sendAlert', function(data)
    local src = source
    sendAlert(src, data)
end)
