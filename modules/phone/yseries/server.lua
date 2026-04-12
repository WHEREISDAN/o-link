if GetResourceState('yseries') ~= 'started' then return end

olink._register('phone', {
    ---@return string
    GetPhoneName = function()
        return 'yseries'
    end,

    ---@return string
    GetResourceName = function()
        return 'yseries'
    end,

    ---@param src number
    ---@return number|boolean
    GetPlayerPhone = function(src)
        return exports.yseries:GetPhoneNumberBySourceId(src) or false
    end,

    ---@param src number
    ---@param email string
    ---@param title string
    ---@param message string
    ---@return boolean
    SendEmail = function(src, email, title, message)
        local phoneNumber = exports.yseries:GetPhoneNumberBySourceId(src)
        if not phoneNumber then return false end
        local _, received = exports.yseries:SendMail({
            title = title,
            sender = email,
            senderDisplayName = email,
            content = message,
        }, 'phoneNumber', phoneNumber)
        return received
    end,
})

RegisterNetEvent('o-link:phone:yseries:sendEmail', function(data)
    local src = source
    olink.phone.SendEmail(src, data.email, data.title, data.message)
end)
