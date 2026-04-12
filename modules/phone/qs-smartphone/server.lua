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

    ---@param src number
    ---@return number|boolean
    GetPlayerPhone = function(src)
        return exports['qs-base']:GetPlayerPhone(src) or false
    end,

    ---@param src number
    ---@param email string
    ---@param title string
    ---@param message string
    ---@return boolean
    SendEmail = function(src, email, title, message)
        TriggerClientEvent('o-link:phone:qs-smartphone:sendEmail', src, { sender = email, subject = title, message = message, button = {} })
        return true
    end,
})
