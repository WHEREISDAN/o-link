if GetResourceState('fivem-appearance') ~= 'started' then return end
if GetResourceState('rcore_clothing') == 'started' then return end
if GetResourceState('17mov_CharacterSystem') == 'started' then return end

local Players = {}

local function getFullAppearanceData(src)
    src = tonumber(src)
    if not src then return end
    local charId = olink.character.GetIdentifier(src)
    if not charId then return end
    if Players[charId] then return Players[charId] end

    local model, skinData
    if olink.framework.GetName() == 'es_extended' then
        local result = MySQL.query.await('SELECT skin FROM users WHERE identifier = ?', { charId })
        if not result or not result[1] then return end
        model = GetEntityModel(GetPlayerPed(src))
        skinData = json.decode(result[1].skin)
    else
        local result = MySQL.query.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', { charId, 1 })
        if not result or not result[1] then return end
        model = result[1].model
        skinData = json.decode(result[1].skin)
    end

    Players[charId] = { model = model, skin = skinData, converted = skinData }
    return Players[charId]
end

olink._register('clothing', {
    ---@return string
    GetResourceName = function()
        return 'fivem-appearance'
    end,

    ---@param src number
    ---@param fullData boolean|nil
    ---@return table|nil
    GetAppearance = function(src, fullData)
        local data = getFullAppearanceData(src)
        if not data then return nil end
        return fullData and data or data.converted
    end,

    ---@param src number
    ---@param data table
    ---@param updateBackup boolean|nil
    ---@param save boolean|nil
    ---@return table|nil
    SetAppearance = function(src, data, updateBackup, save)
        src = tonumber(src)
        if not src then return end
        local charId = olink.character.GetIdentifier(src)
        if not charId then return end
        local current = getFullAppearanceData(src)
        if not current then return end

        for k, v in pairs(data) do
            current.skin[k] = v
        end

        if not Players[charId].backup or updateBackup then
            Players[charId].backup = current.converted
        end
        Players[charId].skin = current.skin
        Players[charId].model = GetEntityModel(GetPlayerPed(src))
        Players[charId].converted = data

        if save then
            MySQL.update.await('UPDATE playerskins SET skin = ? WHERE citizenid = ? AND active = ?', {
                json.encode(current.skin), charId, 1,
            })
        end
        TriggerClientEvent('o-link:client:clothing:setAppearance', src, Players[charId].converted)
        return Players[charId]
    end,

    ---@param src number
    ---@param data table
    SetAppearanceExt = function(src, data)
        local isMale = olink.clothing.IsMale(src)
        local tbl = isMale and data.male or data.female
        olink.clothing.SetAppearance(src, tbl)
    end,

    ---@param src number
    ---@return table|nil
    Revert = function(src)
        src = tonumber(src)
        if not src then return end
        local current = getFullAppearanceData(src)
        if not current or not current.backup then return end
        return olink.clothing.SetAppearance(src, current.backup)
    end,

    ---@param src number
    OpenMenu = function(src)
        src = tonumber(src)
        if not src then return end
        TriggerClientEvent('qb-clothing:client:openMenu', src)
    end,

    ---@param src number
    ---@return boolean
    IsMale = function(src)
        src = tonumber(src)
        if not src then return false end
        local data = getFullAppearanceData(src)
        if data and data.model then
            return data.model == GetHashKey('mp_m_freemode_01')
        end
        local ped = GetPlayerPed(src)
        if not ped or not DoesEntityExist(ped) then return false end
        return GetEntityModel(ped) == GetHashKey('mp_m_freemode_01')
    end,
})

AddEventHandler('olink:server:playerReady', function(src)
    src = tonumber(src)
    if not src then return end
    getFullAppearanceData(src)
end)

AddEventHandler('olink:server:playerUnload', function(src)
    src = tonumber(src)
    if not src then return end
    local charId = olink.character.GetIdentifier(src)
    if charId then Players[charId] = nil end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, playerId in ipairs(GetPlayers()) do
        local src = tonumber(playerId)
        if src then getFullAppearanceData(src) end
    end
end)
