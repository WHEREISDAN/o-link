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

    ---@param email string
    ---@param title string
    ---@param message string
    ---@return boolean
    SendEmail = function(email, title, message)
        TriggerServerEvent('o-link:phone:yseries:sendEmail', { email = email, title = title, message = message })
        return true
    end,
})
