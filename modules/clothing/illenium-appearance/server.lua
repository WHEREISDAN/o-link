if GetResourceState('illenium-appearance') == 'missing' then return end
if GetResourceState('rcore_clothing') == 'started' then return end
if GetResourceState('17mov_CharacterSystem') == 'started' then return end

local Players = {}

local function getFullAppearanceData(src)
    src = tonumber(src)
    if not src then return end
    local charId = olink.character.GetIdentifier(src)
    if not charId then return end
    if Players[charId] then return Players[charId] end

    local result = MySQL.query.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', { charId, 1 })
    if not result or not result[1] then return end

    local model = result[1].model
    local skinData = json.decode(result[1].skin)

    Players[charId] = { model = model, skin = skinData, converted = skinData }
    return Players[charId]
end

olink._register('clothing', {
    ---@return string
    GetResourceName = function()
        return 'illenium-appearance'
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

    ---@param src number
    ---@param name string
    ---@param data table
    ---@return number|nil
    SaveOutfit = function(src, name, data)
        local charId = olink.character.GetIdentifier(src)
        if not charId then return nil end
        local model = GetEntityModel(GetPlayerPed(src))
        return MySQL.insert.await(
            'INSERT INTO player_outfits (citizenid, outfitname, model, components, props) VALUES (?, ?, ?, ?, ?)',
            { charId, name, tostring(model), json.encode(data.components or {}), json.encode(data.props or {}) }
        )
    end,

    ---@param src number
    ---@return table[]
    GetOutfits = function(src)
        local charId = olink.character.GetIdentifier(src)
        if not charId then return {} end
        local rows = MySQL.query.await('SELECT * FROM player_outfits WHERE citizenid = ?', { charId })
        if not rows then return {} end
        local outfits = {}
        for _, row in ipairs(rows) do
            local components = type(row.components) == 'string' and json.decode(row.components) or row.components
            local props = type(row.props) == 'string' and json.decode(row.props) or row.props
            outfits[#outfits + 1] = {
                outfitId = row.id,
                name = row.outfitname,
                components = components or {},
                props = props or {},
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
        local affected = MySQL.update.await(
            'UPDATE player_outfits SET outfitname = ?, components = ?, props = ? WHERE id = ?',
            { name, json.encode(data.components or {}), json.encode(data.props or {}), tonumber(outfitId) }
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
