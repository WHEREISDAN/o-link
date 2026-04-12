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

    ---@param email string
    ---@param title string
    ---@param message string
    SendEmail = function(email, title, message)
        TriggerServerEvent('o-link:phone:okokPhone:sendEmail', { email = email, title = title, message = message })
    end,
})
