if GetResourceState('okokPhone') ~= 'started' then return end

olink._register('phone', {
    ---@return string
    GetPhoneName = function()
        return 'okokPhone'
    end,

    ---@return string
    GetResourceName = function()
        return 'okokPhone'
    end,

    ---@param src number
    ---@return number|boolean
    GetPlayerPhone = function(src)
        return exports.okokPhone:getPhoneNumberFromSource(src) or false
    end,

    ---@param src number
    ---@param email string
    ---@param title string
    ---@param message string
    ---@return boolean
    SendEmail = function(src, email, title, message)
        local playerEmail = exports.okokPhone:getEmailAddressFromSource(src)
        if not playerEmail then return false end
        local success = exports.okokPhone:sendEmail({
            sender = email,
            recipients = { playerEmail },
            subject = title,
            body = message,
        })
        return success or false
    end,
})

RegisterNetEvent('o-link:phone:okokPhone:sendEmail', function(data)
    local src = source
    olink.phone.SendEmail(src, data.email, data.title, data.message)
end)
