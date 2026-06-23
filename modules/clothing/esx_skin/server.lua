if not olink._guardImpl('Clothing', 'esx_skin', 'esx_skin') then return end
if not olink._hasOverride('Clothing') and GetResourceState('rcore_clothing') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('17mov_CharacterSystem') == 'started' then return end

local Players = {}

local function getFullAppearanceData(src)
    src = tonumber(src)
    if not src then return end
    local charId = olink.character.GetIdentifier(src)
    if not charId then return end
    if Players[charId] then return Players[charId] end

    local result = MySQL.query.await('SELECT skin FROM users WHERE identifier = ?', { charId })
    if not result or not result[1] then return end

    local model = GetEntityModel(GetPlayerPed(src))
    local skinData = json.decode(result[1].skin)
    local converted = EsxSkinConvertToDefault(skinData)

    Players[charId] = { model = model, skin = skinData, converted = converted }
    return Players[charId]
end

local function getPlayerDressing(identifier)
    local row = MySQL.single.await(
        "SELECT data FROM datastore_data WHERE name = 'property' AND owner = ?",
        { identifier }
    )
    if not row or not row.data then return {} end
    local data = type(row.data) == 'string' and json.decode(row.data) or row.data
    return data.dressing or {}
end

local function savePlayerDressing(identifier, dressing)
    local row = MySQL.single.await(
        "SELECT id FROM datastore_data WHERE name = 'property' AND owner = ?",
        { identifier }
    )
    local encoded = json.encode({ dressing = dressing })
    if row then
        MySQL.update.await("UPDATE datastore_data SET data = ? WHERE name = 'property' AND owner = ?", { encoded, identifier })
    else
        MySQL.insert.await("INSERT INTO datastore_data (name, owner, data) VALUES ('property', ?, ?)", { identifier, encoded })
    end
end

olink._register('clothing', {
    ---@return string
    GetResourceName = function()
        return 'esx_skin'
    end,

    ---@param src number
    ---@param fullData boolean|nil
    ---@return table|nil
    GetAppearance = function(src, fullData)
        local data = getFullAppearanceData(src)
        if not data then return nil end
        return fullData and data or data.converted
    end,

    ---Rich canonical snapshot (merge base for partial appearance edits). esx_skin
    ---stores the full skinchanger skin in users.skin, so invert it into canonical.
    ---@param src number
    ---@return table|nil
    GetCanonicalAppearance = function(src)
        local data = getFullAppearanceData(src)
        if not data or type(data.skin) ~= 'table' then return nil end
        return EsxSkinToCanonical(data.skin)
    end,

    ---Persist a canonical look. Only the styling fields (hair / overlays / eye
    ---colour) are written over the stored skinchanger skin, so head blend, face
    ---features and clothing are preserved; then skinchanger re-applies it live.
    ---@param src number
    ---@param data table canonical appearance
    ---@param save boolean|nil unused (always persists)
    ---@return boolean
    SaveCreatorAppearance = function(src, data, save)
        src = tonumber(src)
        if not src or type(data) ~= 'table' then return false end
        local charId = olink.character.GetIdentifier(src)
        if not charId then return false end
        local current = getFullAppearanceData(src)
        if not current or type(current.skin) ~= 'table' then return false end

        local flat = CanonicalToEsxFlat(data)
        for k, v in pairs(flat) do current.skin[k] = v end
        current.converted = EsxSkinConvertToDefault(current.skin)

        MySQL.update.await('UPDATE users SET skin = ? WHERE identifier = ?', {
            json.encode(current.skin), charId,
        })
        TriggerClientEvent('skinchanger:loadSkin', src, current.skin)
        return true
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
        -- Re-read DB before a fresh backup; cache isn't invalidated on external writes.
        if not Players[charId] or not Players[charId].backup then
            Players[charId] = nil
        end
        local current = getFullAppearanceData(src)
        if not current then return end

        local converted = EsxSkinConvertFromDefault(data)
        for k, v in pairs(converted) do
            current.skin[k] = v
        end

        if not Players[charId].backup or updateBackup then
            Players[charId].backup = current.converted
        end
        Players[charId].skin = current.skin
        Players[charId].model = GetEntityModel(GetPlayerPed(src))
        Players[charId].converted = EsxSkinConvertToDefault(current.skin)

        if save then
            MySQL.update.await('UPDATE users SET skin = ? WHERE identifier = ?', { json.encode(current.skin), charId })
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

    ---Flushes the cached skin to the database without requiring a SetAppearance call.
    ---@param src number
    ---@return boolean
    Save = function(src)
        src = tonumber(src)
        if not src then return false end
        local charId = olink.character.GetIdentifier(src)
        if not charId then return false end
        local current = getFullAppearanceData(src)
        if not current or not current.skin then return false end
        MySQL.update.await('UPDATE users SET skin = ? WHERE identifier = ?', {
            json.encode(current.skin), charId,
        })
        return true
    end,

    ---@param src number
    OpenMenu = function(src)
        src = tonumber(src)
        if not src then return end
        TriggerClientEvent('esx_skin:openMenu', src)
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
        local skin = EsxSkinConvertFromDefault(data)
        local dressing = getPlayerDressing(charId)
        dressing[#dressing + 1] = { label = name, skin = skin }
        savePlayerDressing(charId, dressing)
        return #dressing
    end,

    ---@param src number
    ---@return table[]
    GetOutfits = function(src)
        local charId = olink.character.GetIdentifier(src)
        if not charId then return {} end
        local dressing = getPlayerDressing(charId)
        local outfits = {}
        for i, outfit in ipairs(dressing) do
            local converted = EsxSkinConvertToDefault(outfit.skin or {})
            outfits[#outfits + 1] = {
                outfitId = i,
                name = outfit.label,
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
        local charId = olink.character.GetIdentifier(src)
        if not charId then return false end
        local idx = tonumber(outfitId)
        if not idx then return false end
        local dressing = getPlayerDressing(charId)
        if not dressing[idx] then return false end
        dressing[idx].label = name
        dressing[idx].skin = EsxSkinConvertFromDefault(data)
        savePlayerDressing(charId, dressing)
        return true
    end,

    ---@param src number
    ---@param outfitId number
    ---@return boolean
    DeleteOutfit = function(src, outfitId)
        local charId = olink.character.GetIdentifier(src)
        if not charId then return false end
        local idx = tonumber(outfitId)
        if not idx then return false end
        local dressing = getPlayerDressing(charId)
        if not dressing[idx] then return false end
        table.remove(dressing, idx)
        savePlayerDressing(charId, dressing)
        return true
    end,

    ---Offline appearance snapshot keyed by ESX identifier. esx_skin stores a
    ---flat numeric table (`{ tshirt_1 = 0, pants_1 = 0, ... }`) which we
    ---convert to default shape for cross-framework preview rendering.
    ---@param charId string ESX identifier (e.g. "char1:license:abc")
    ---@return table|nil
    GetOfflineAppearance = function(charId)
        if not charId then return nil end
        local row = MySQL.single.await('SELECT skin, sex FROM users WHERE identifier = ?', { tostring(charId) })
        if not row or not row.skin then return nil end

        local skin = type(row.skin) == 'string' and json.decode(row.skin) or row.skin
        if type(skin) ~= 'table' then return nil end

        local converted = EsxSkinConvertToDefault(skin)
        local model = (skin.sex == 1 or row.sex == 'f' or row.sex == 'F') and 'mp_f_freemode_01' or 'mp_m_freemode_01'
        return {
            framework  = 'esx_skin',
            model      = model,
            components = converted.components,
            props      = converted.props,
            skin       = skin,
        }
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
