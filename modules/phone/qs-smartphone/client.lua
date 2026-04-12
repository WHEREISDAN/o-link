if GetResourceState('qs-smartphone') ~= 'started' then return end

olink._register('phone', {
    ---@return string
    GetPhoneName = function()
        return 'qs-smartphone'
    end,

    ---@return string
    GetResourceName = function()
        return 'qs-smartphone'
    end,

    ---@param email string
    ---@param title string
    ---@param message string
    ---@return boolean
    SendEmail = function(email, title, message)
        TriggerServerEvent('qs-smartphone:server:sendNewMail', { sender = email, subject = title, message = message, button = {} })
        return true
    end,
})

RegisterNetEvent('o-link:phone:qs-smartphone:sendEmail', function(data)
    TriggerServerEvent('qs-smartphone:server:sendNewMail', { sender = data.sender, subject = data.subject, message = data.message, button = {} })
end)
