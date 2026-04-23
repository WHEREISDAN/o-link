if not olink._guardImpl('Phone', 'oxide-phone', 'oxide-phone') then return end

olink._register('phone', {
    ---@return string
    GetPhoneName = function()
        return 'oxide-phone'
    end,

    ---@return string
    GetResourceName = function()
        return 'oxide-phone'
    end,

    ---@param email string
    ---@param title string
    ---@param message string
    ---@return boolean
    SendEmail = function(email, title, message)
        TriggerServerEvent('o-link:phone:oxide-phone:sendEmail', { email = email, title = title, message = message })
        return true
    end,
})
