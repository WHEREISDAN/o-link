if not olink._guardImpl('Clothing', 'illenium-appearance', 'illenium-appearance') then return end
if not olink._hasOverride('Clothing') and GetResourceState('rcore_clothing') == 'started' then return end
if not olink._hasOverride('Clothing') and GetResourceState('17mov_CharacterSystem') == 'started' then return end

local Players = {}

-- illenium stores the active skin in a different place per framework: QBCore/OX
-- use the `playerskins` table (keyed by citizenid); ESX stores it in `users.skin`
-- (keyed by identifier). The o-link key (olink.character.GetIdentifier / List
-- charId) is the full ESX identifier ("char1:license:..."), which matches
-- illenium's own Player.identifier — so the same key works for both schemas.
local IS_ESX = GetResourceState('es_extended') == 'started'

---Read the active skin for a character key.
---@param key string citizenid (QB/OX) or identifier (ESX)
---@return string|nil model, table|nil skin
local function readActiveSkin(key)
    if not key then return nil end
    local row
    if IS_ESX then
        row = MySQL.single.await('SELECT skin FROM users WHERE identifier = ?', { tostring(key) })
    else
        row = MySQL.single.await('SELECT model, skin FROM playerskins WHERE citizenid = ? AND active = ?', { tostring(key), 1 })
    end
    if not row or not row.skin then return nil end
    local skin = type(row.skin) == 'string' and json.decode(row.skin) or row.skin
    if type(skin) ~= 'table' then return nil end
    return row.model or skin.model or 'mp_m_freemode_01', skin
end

---Persist the active skin for a character key. ESX updates users.skin (the row
---always exists); QB/OX upsert the active playerskins row.
---@param key string
---@param model string
---@param encoded string json-encoded skin
local function writeActiveSkin(key, model, encoded)
    if IS_ESX then
        MySQL.update.await('UPDATE users SET skin = ? WHERE identifier = ?', { encoded, tostring(key) })
        return
    end
    local affected = MySQL.update.await(
        'UPDATE playerskins SET skin = ?, model = ? WHERE citizenid = ? AND active = ?',
        { encoded, model, tostring(key), 1 }
    )
    if not affected or affected == 0 then
        MySQL.insert.await(
            'INSERT INTO playerskins (citizenid, model, skin, active) VALUES (?, ?, ?, ?)',
            { tostring(key), model, encoded, 1 }
        )
    end
end

local function getFullAppearanceData(src)
    src = tonumber(src)
    if not src then return end
    local charId = olink.character.GetIdentifier(src)
    if not charId then return end
    if Players[charId] then return Players[charId] end

    local model, skinData = readActiveSkin(charId)
    if not skinData then return end

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
        -- Re-read DB before a fresh backup; cache isn't invalidated on external writes.
        if not Players[charId] or not Players[charId].backup then
            Players[charId] = nil
        end
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
            if IS_ESX then
                MySQL.update.await('UPDATE users SET skin = ? WHERE identifier = ?', {
                    json.encode(current.skin), charId,
                })
            else
                MySQL.update.await('UPDATE playerskins SET skin = ? WHERE citizenid = ? AND active = ?', {
                    json.encode(current.skin), charId, 1,
                })
            end
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

    ---Offline appearance snapshot for a character. illenium stores the rich
    ---appearance object directly in its skin blob (components/props are already
    ---default-shape); readActiveSkin pulls it from the right place per framework
    ---(playerskins for QB/OX, users.skin for ESX), so we just tag the payload.
    ---@param charId string citizenid (QB/OX) or identifier (ESX)
    ---@return table|nil
    GetOfflineAppearance = function(charId)
        if not charId then return nil end
        local model, skin = readActiveSkin(charId)
        if not skin then return nil end

        return {
            framework    = 'illenium-appearance',
            model        = model or skin.model or 'mp_m_freemode_01',
            components   = skin.components or {},
            props        = skin.props or {},
            headBlend    = skin.headBlend,
            faceFeatures = skin.faceFeatures,
            headOverlays = skin.headOverlays,
            hair         = skin.hair,
            eyeColor     = skin.eyeColor,
            tattoos      = skin.tattoos,
        }
    end,

    ---Persist a full look produced by oxide-multichar's built-in creator.
    ---The canonical object is translated into illenium's `skin` shape and
    ---written to the active skin store via writeActiveSkin (users.skin on ESX,
    ---playerskins on QB/OX). The live ped is already set by the creator;
    ---illenium re-applies from here on the next character load.
    ---@param src number
    ---@param data table canonical creator appearance
    ---@param save boolean|nil unused (always persists)
    ---@return boolean
    SaveCreatorAppearance = function(src, data, save)
        src = tonumber(src)
        if not src or type(data) ~= 'table' then return false end
        local charId = olink.character.GetIdentifier(src)
        if not charId then return false end

        local skin = OlinkCreatorToIllenium(data)
        writeActiveSkin(charId, skin.model, json.encode(skin))

        Players[charId] = nil
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
