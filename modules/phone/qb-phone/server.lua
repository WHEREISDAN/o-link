if GetResourceState('qb-phone') == 'missing' then return end
if GetResourceState('lb-phone') == 'started' then return end
if GetResourceState('gksphone') == 'started' then return end
if GetResourceState('okokPhone') == 'started' then return end
if GetResourceState('qs-smartphone') == 'started' then return end
if GetResourceState('yseries') == 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

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
        local player = QBCore.Functions.GetPlayer(src)
        if not player then return false end
        return player.PlayerData.charinfo and player.PlayerData.charinfo.phone or false
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
