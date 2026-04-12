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

    ---@param src number
    ---@return number|boolean
    GetPlayerPhone = function(src)
        return exports['gksphone']:GetPhoneBySource(src) or false
    end,

    ---@param src number
    ---@param email string
    ---@param title string
    ---@param message string
    ---@return boolean
    SendEmail = function(src, email, title, message)
        local data = {
            sender = email,
            image = '/html/static/img/icons/mail.png',
            subject = title,
            message = message,
        }
        exports['gksphone']:SendNewMail(src, data)
        return true
    end,
})
