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

    ---@param src number
    ---@return number|boolean
    GetPlayerPhone = function(src)
        return exports['lb-phone']:GetEquippedPhoneNumber(src) or false
    end,

    ---@param src number
    ---@param email string
    ---@param title string
    ---@param message string
    ---@return boolean
    SendEmail = function(src, email, title, message)
        local phoneNumber = exports['lb-phone']:GetEquippedPhoneNumber(src)
        if not phoneNumber then return false end
        local playerEmail = exports['lb-phone']:GetEmailAddress(phoneNumber)
        if not playerEmail then return false end
        local success = exports['lb-phone']:SendMail({
            to = playerEmail,
            sender = email,
            subject = title,
            message = message,
        })
        return success or false
    end,
})

RegisterNetEvent('o-link:phone:lb-phone:sendEmail', function(data)
    local src = source
    olink.phone.SendEmail(src, data.email, data.title, data.message)
end)
