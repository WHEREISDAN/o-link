if GetResourceState('gksphone') ~= 'started' then return end

olink._register('phone', {
    ---@return string
    GetPhoneName = function()
        return 'gksphone'
    end,

    ---@return string
    GetResourceName = function()
        return 'gksphone'
    end,

    ---@param email string
    ---@param title string
    ---@param message string
    ---@return boolean
    SendEmail = function(email, title, message)
        return exports['gksphone']:SendNewMail({
            sender = email,
            image = '/html/static/img/icons/mail.png',
            subject = title,
            message = message,
        })
    end,
})
