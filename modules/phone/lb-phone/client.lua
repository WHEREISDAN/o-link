if GetResourceState('lb-phone') == 'missing' then return end

olink._register('phone', {
    ---@return string
    GetPhoneName = function()
        return 'lb-phone'
    end,

    ---@return string
    GetResourceName = function()
        return 'lb-phone'
    end,

    ---@param email string
    ---@param title string
    ---@param message string
    SendEmail = function(email, title, message)
        TriggerServerEvent('o-link:phone:lb-phone:sendEmail', { email = email, title = title, message = message })
    end,
})
