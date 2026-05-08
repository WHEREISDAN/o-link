if not olink._guardImpl('Clothing', 'oxide-identity', 'oxide-identity') then return end

local Players = {}

-- oxide-identity keys character_clothing on the numeric char_id, not the
-- state_id returned by olink.character.GetIdentifier.
local function getNumericCharId(src)
    local ok, core = pcall(function() return exports['oxide-core']:Core() end)
    if not ok or not core or not core.Functions then return nil end
    local player = core.Functions.GetPlayer(src)
    if not player or not player.GetCharacter then return nil end
    local char = player.GetCharacter()
    if not char or not char.charId then return nil end
    return tonumber(char.charId)
end

local function syncClothingState(src, clothing)
    local player = Player(src)
    if player and player.state then
        player.state:set('oxide:clothing', clothing, true)
    end
end

local function normalizeNativeMap(tbl)
    local out = {}
    for k, v in pairs(tbl or {}) do
        out[tonumber(k) or k] = v
    end
    return out
end

local function getFullAppearanceData(src)
    src = tonumber(src)
    if not src then return end
    local charId = getNumericCharId(src)
    if not charId then return end
    if Players[charId] then return Players[charId] end

    local clothingResult = MySQL.query.await('SELECT * FROM character_clothing WHERE char_id = ?', { charId })
    if not clothingResult or not clothingResult[1] then return end

    local appearanceResult = MySQL.query.await('SELECT model FROM character_appearance WHERE char_id = ?', { charId })
    local components = normalizeNativeMap(json.decode(clothingResult[1].components) or {})
    local props = normalizeNativeMap(json.decode(clothingResult[1].props) or {})
    local model = appearanceResult and appearanceResult[1] and appearanceResult[1].model or 'mp_m_freemode_01'
    local nativeData = { components = components, props = props }

    Players[charId] = {
        model = model,
        native = nativeData,
        converted = OxideIdentityConvertToDefault(nativeData),
    }
    return Players[charId]
end

olink._register('clothing', {
    ---@return string
    GetResourceName = function()
        return 'oxide-identity'
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
        local charId = getNumericCharId(src)
        if not charId then return end
        -- Re-read DB before a fresh backup; cache isn't invalidated on external writes.
        if not Players[charId] or not Players[charId].backup then
            Players[charId] = nil
        end
        local current = getFullAppearanceData(src)
        if not current then return end

        local incoming = OxideIdentityConvertFromDefault(data)
        for k, v in pairs(incoming.components or {}) do
            current.native.components[k] = v
        end
        for k, v in pairs(incoming.props or {}) do
            current.native.props[k] = v
        end

        if not Players[charId].backup or updateBackup then
            Players[charId].backup = current.converted
        end
        Players[charId].native = current.native
        Players[charId].converted = OxideIdentityConvertToDefault(current.native)
        syncClothingState(src, Players[charId].native)

        if save then
            MySQL.update.await('UPDATE character_clothing SET components = ?, props = ? WHERE char_id = ?', {
                json.encode(current.native.components), json.encode(current.native.props), charId,
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
        return olink.clothing.SetAppearance(src, tbl)
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
        TriggerClientEvent('o-link:client:clothing:openMenu', src)
    end,

    ---@param src number
    ---@return boolean
    IsMale = function(src)
        src = tonumber(src)
        if not src then return false end
        local data = getFullAppearanceData(src)
        if data and data.model then
            return data.model == 'mp_m_freemode_01'
        end
        local ped = GetPlayerPed(src)
        if not ped or not DoesEntityExist(ped) then return false end
        return GetEntityModel(ped) == `mp_m_freemode_01`
    end,

    ---@param src number
    ---@param name string
    ---@param data table
    ---@return number|nil
    SaveOutfit = function(src, name, data)
        local charId = getNumericCharId(src)
        if not charId then return nil end
        local native = OxideIdentityConvertFromDefault(data)
        return exports['oxide-identity']:SaveOutfit(charId, name, native.components, native.props)
    end,

    ---@param src number
    ---@return table[]
    GetOutfits = function(src)
        local charId = getNumericCharId(src)
        if not charId then return {} end
        local outfits = exports['oxide-identity']:GetOutfits(charId)
        if not outfits then return {} end
        for i, outfit in ipairs(outfits) do
            local converted = OxideIdentityConvertToDefault({ components = outfit.components, props = outfit.props })
            outfits[i].components = converted.components
            outfits[i].props = converted.props
        end
        return outfits
    end,

    ---@param src number
    ---@param outfitId number
    ---@param name string
    ---@param data table
    ---@return boolean
    UpdateOutfit = function(src, outfitId, name, data)
        local native = OxideIdentityConvertFromDefault(data)
        return exports['oxide-identity']:UpdateOutfit(tonumber(outfitId), name, native.components, native.props)
    end,

    ---@param src number
    ---@param outfitId number
    ---@return boolean
    DeleteOutfit = function(src, outfitId)
        return exports['oxide-identity']:DeleteOutfit(tonumber(outfitId))
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
    local charId = getNumericCharId(src)
    if charId then Players[charId] = nil end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, playerId in ipairs(GetPlayers()) do
        local src = tonumber(playerId)
        if src then getFullAppearanceData(src) end
    end
end)
