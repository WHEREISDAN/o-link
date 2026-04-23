if not olink._guardImpl('Phone', 'qb-phone', 'qb-phone') then return end
if not olink._hasOverride('Phone') and GetResourceState('lb-phone') == 'started' then return end
if not olink._hasOverride('Phone') and GetResourceState('gksphone') == 'started' then return end
if not olink._hasOverride('Phone') and GetResourceState('okokPhone') == 'started' then return end
if not olink._hasOverride('Phone') and GetResourceState('qs-smartphone') == 'started' then return end
if not olink._hasOverride('Phone') and GetResourceState('yseries') == 'started' then return end

olink._register('phone', {
    ---@return string
    GetPhoneName = function()
        return 'qb-phone'
    end,

    ---@return string
    GetResourceName = function()
        return 'qb-phone'
    end,

    ---@param src number
    ---@return number|boolean
    GetPlayerPhone = function(src)
        local identifier = olink.character.GetIdentifier(src)
        if not identifier then return false end

        local row = MySQL.single.await('SELECT charinfo FROM players WHERE citizenid = ?', { identifier })
        if not row or not row.charinfo then return false end

        local charinfo = row.charinfo
        if type(charinfo) == 'string' then
            local ok, decoded = pcall(json.decode, charinfo)
            if not ok or type(decoded) ~= 'table' then return false end
            charinfo = decoded
        end

        return type(charinfo) == 'table' and charinfo.phone or false
    end,

    ---@param src number
    ---@param email string
    ---@param title string
    ---@param message string
    ---@return boolean
    SendEmail = function(src, email, title, message)
        local identifier = olink.character.GetIdentifier(src)
        if not identifier then return false end
        local mailData = { sender = email, subject = title, message = message }
        exports['qb-phone']:sendNewMailToOffline(identifier, mailData)
        return true
    end,
})

RegisterNetEvent('o-link:phone:qb-phone:sendEmail', function(data)
    local src = source
    olink.phone.SendEmail(src, data.email, data.title, data.message)
end)
