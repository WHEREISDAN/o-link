if GetResourceState('qb-phone') ~= 'started' then return end
if GetResourceState('lb-phone') == 'started' then return end
if GetResourceState('gksphone') == 'started' then return end
if GetResourceState('okokPhone') == 'started' then return end
if GetResourceState('qs-smartphone') == 'started' then return end
if GetResourceState('yseries') == 'started' then return end

olink._register('phone', {
    ---@return string
    GetPhoneName = function()
        return 'qb-phone'
    end,

    ---@return string
    GetResourceName = function()
        return 'qb-phone'
    end,

    ---@param email string
    ---@param title string
    ---@param message string
    SendEmail = function(email, title, message)
        TriggerServerEvent('o-link:phone:qb-phone:sendEmail', { email = email, title = title, message = message })
    end,
})
