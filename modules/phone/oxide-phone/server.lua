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

    ---@param src number
    ---@return string|boolean
    GetPlayerPhone = function(src)
        local ok, result = pcall(exports['oxide-phone'].GetPhoneNumber, exports['oxide-phone'], src)
        if ok and result then return result end
        return false
    end,

    ---@param src number
    ---@param email string
    ---@param title string
    ---@param message string
    ---@return boolean
    SendEmail = function(src, email, title, message)
        local ok, playerEmail = pcall(exports['oxide-phone'].GetEmailAddress, exports['oxide-phone'], src)
        if not ok or not playerEmail then return false end
        local ok2, result = pcall(exports['oxide-phone'].SendServiceEmail, exports['oxide-phone'],
            email, email .. '@service.com', playerEmail, title, message)
        if ok2 then return result ~= nil end
        return false
    end,
})

RegisterNetEvent('o-link:phone:oxide-phone:sendEmail', function(data)
    local src = source
    olink.phone.SendEmail(src, data.email, data.title, data.message)
end)
