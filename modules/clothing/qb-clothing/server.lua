if not olink._guardImpl('Clothing', 'qb-clothing', 'qb-clothing') then return end
if not olink._hasOverride('Clothing') and GetResourceState('oxide-clothing') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('rcore_clothing') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('17mov_CharacterSystem') == 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()
local Players = {}

local function getCitId(src)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player and Player.PlayerData.citizenid or nil
end

local function getFullAppearanceData(src)
    src = tonumber(src)
    if not src then return end
    local citId = getCitId(src)
    if not citId then return end
    if Players[citId] then return Players[citId] end

    local result = MySQL.query.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', { citId, 1 })
    if not result or not result[1] then return end

    local Player = QBCore.Functions.GetPlayer(src)
    local model = Player and Player.PlayerData.model or nil
    local skinData = json.decode(result[1].skin)

    Players[citId] = {
        model = model,
        skin = skinData,
        converted = QbClothingConvertToDefault(skinData),
    }
    return Players[citId]
end

olink._register('clothing', {
    ---@return string
    GetResourceName = function()
        return 'qb-clothing'
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
        local citId = getCitId(src)
        if not citId then return end
        -- Re-read DB before a fresh backup; cache isn't invalidated on external writes.
        if not Players[citId] or not Players[citId].backup then
            Players[citId] = nil
        end
        local current = getFullAppearanceData(src)
        if not current then return end

        local converted = QbClothingConvertFromDefault(data)
        for k, v in pairs(converted) do
            current.skin[k] = v
        end

        if not Players[citId].backup or updateBackup then
            Players[citId].backup = current.converted
        end
        Players[citId].skin = current.skin
        Players[citId].model = GetEntityModel(GetPlayerPed(src))
        Players[citId].converted = QbClothingConvertToDefault(current.skin)

        if save then
            MySQL.update.await('UPDATE playerskins SET skin = ? WHERE citizenid = ? AND active = ?', {
                json.encode(current.skin), citId, 1,
            })
        end
        TriggerClientEvent('o-link:client:clothing:setAppearance', src, Players[citId].converted)
        return Players[citId]
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

    ---@param src number
    ---@param name string
    ---@param data table
    ---@return number|nil
    SaveOutfit = function(src, name, data)
        local citId = getCitId(src)
        if not citId then return nil end
        local model = GetEntityModel(GetPlayerPed(src))
        local skin = QbClothingConvertFromDefault(data)
        local outfitId = 'outfit-' .. math.random(1, 10) .. '-' .. math.random(1111, 9999)
        return MySQL.insert.await(
            'INSERT INTO player_outfits (citizenid, outfitname, model, skin, outfitId) VALUES (?, ?, ?, ?, ?)',
            { citId, name, tostring(model), json.encode(skin), outfitId }
        )
    end,

    ---@param src number
    ---@return table[]
    GetOutfits = function(src)
        local citId = getCitId(src)
        if not citId then return {} end
        local rows = MySQL.query.await('SELECT * FROM player_outfits WHERE citizenid = ?', { citId })
        if not rows then return {} end
        local outfits = {}
        for _, row in ipairs(rows) do
            local skin = type(row.skin) == 'string' and json.decode(row.skin) or row.skin
            local converted = QbClothingConvertToDefault(skin or {})
            outfits[#outfits + 1] = {
                outfitId = row.id,
                name = row.outfitname,
                components = converted.components,
                props = converted.props,
            }
        end
        return outfits
    end,

    ---@param src number
    ---@param outfitId number
    ---@param name string
    ---@param data table
    ---@return boolean
    UpdateOutfit = function(src, outfitId, name, data)
        local skin = QbClothingConvertFromDefault(data)
        local affected = MySQL.update.await(
            'UPDATE player_outfits SET outfitname = ?, skin = ? WHERE id = ?',
            { name, json.encode(skin), tonumber(outfitId) }
        )
        return affected and affected > 0
    end,

    ---@param src number
    ---@param outfitId number
    ---@return boolean
    DeleteOutfit = function(src, outfitId)
        local affected = MySQL.update.await(
            'DELETE FROM player_outfits WHERE id = ?',
            { tonumber(outfitId) }
        )
        return affected and affected > 0
    end,

    ---Offline appearance snapshot keyed by citizenid. qb-clothing stores a
    ---flat-keyed skin table (`{ ["pants"] = {item, texture}, ... }`) which we
    ---convert to default shape for cross-framework preview rendering.
    ---@param charId string citizenid
    ---@return table|nil
    GetOfflineAppearance = function(charId)
        if not charId then return nil end
        local row = MySQL.single.await(
            'SELECT model, skin FROM playerskins WHERE citizenid = ? AND active = ?',
            { tostring(charId), 1 }
        )
        if not row or not row.skin then return nil end

        local skin = type(row.skin) == 'string' and json.decode(row.skin) or row.skin
        if type(skin) ~= 'table' then return nil end

        local converted = QbClothingConvertToDefault(skin)
        return {
            framework  = 'qb-clothing',
            model      = row.model or 'mp_m_freemode_01',
            components = converted.components,
            props      = converted.props,
            skin       = skin,
        }
    end,

    ---Persist a full look produced by oxide-multichar's built-in creator.
    ---Writes the rich illenium-shape fields (honored when illenium-appearance is
    ---the active appearance resource on qb-core) plus qb-clothing's flat clothing
    ---keys (so legacy qb-clothing still applies the outfit). Face features only
    ---take effect on appearance resources that read them.
    ---@param src number
    ---@param data table canonical creator appearance
    ---@param save boolean|nil unused (always persists)
    ---@return boolean
    SaveCreatorAppearance = function(src, data, save)
        src = tonumber(src)
        if not src or type(data) ~= 'table' then return false end
        local citId = getCitId(src)
        if not citId then return false end

        local skin = OlinkCreatorToIllenium(data)
        local flat = QbClothingConvertFromDefault({ components = skin.components, props = skin.props })
        for k, v in pairs(flat) do skin[k] = v end

        local encoded = json.encode(skin)
        local affected = MySQL.update.await(
            'UPDATE playerskins SET skin = ?, model = ? WHERE citizenid = ? AND active = ?',
            { encoded, skin.model, citId, 1 }
        )
        if not affected or affected == 0 then
            MySQL.insert.await(
                'INSERT INTO playerskins (citizenid, model, skin, active) VALUES (?, ?, ?, ?)',
                { citId, skin.model, encoded, 1 }
            )
        end

        Players[citId] = nil
        return true
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
    local citId = getCitId(src)
    if citId then Players[citId] = nil end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, playerId in ipairs(GetPlayers()) do
        local src = tonumber(playerId)
        if src then getFullAppearanceData(src) end
    end
end)
