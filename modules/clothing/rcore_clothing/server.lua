if not olink._guardImpl('Clothing', 'rcore_clothing', 'rcore_clothing') then return end
if not olink._hasOverride('Clothing') and GetResourceState('17mov_CharacterSystem') == 'started' then return end

local A = olink._appearance

-- rcore keys its current-outfit row by the framework identifier (ESX identifier /
-- QB citizenid), which is exactly what olink.character.GetIdentifier returns.
local function readOutfit(src)
    local identifier = olink.character.GetIdentifier(src)
    if not identifier then return nil end
    local row = MySQL.single.await(
        'SELECT outfit, ped_model FROM rcore_clothing_current WHERE identifier = ?',
        { identifier }
    )
    if not row or not row.outfit then return nil end
    local outfit = type(row.outfit) == 'string' and json.decode(row.outfit) or row.outfit
    if type(outfit) ~= 'table' then return nil end
    return outfit, row.ped_model
end

local function readCanonical(src)
    local outfit, pedModel = readOutfit(src)
    if not outfit then return nil end
    return RcoreToCanonical(outfit, pedModel)
end

olink._register('clothing', {
    GetResourceName = function() return 'rcore_clothing' end,

    ---Default-shape clothing snapshot for legacy consumers.
    ---@param src number
    ---@return table|nil
    GetAppearance = function(src)
        local canonical = readCanonical(src)
        if not canonical then return nil end
        return {
            framework = 'rcore_clothing',
            model = canonical.model,
            components = A.componentsToArray(canonical.components),
            props = A.propsToArray(canonical.props),
        }
    end,

    ---Rich canonical snapshot — the merge base for partial appearance edits.
    ---@param src number
    ---@return table|nil
    GetCanonicalAppearance = function(src)
        return readCanonical(src)
    end,

    ---Apply (and optionally persist) a clothing/appearance payload. rcore persists
    ---by snapshotting the live ped (`saveCurrentSkin`), so we apply the payload to
    ---the player ped client-side and, when saving, let rcore capture it back into
    ---its own correctly-encoded outfit. The canonical SetAppearance wrapper feeds
    ---rich payloads here already merged over GetCanonicalAppearance, so a partial
    ---edit never drops the rest of the look.
    ---@param src number
    ---@param data table
    ---@param updateBackup boolean|nil
    ---@param save boolean|nil
    SetAppearance = function(src, data, updateBackup, save)
        src = tonumber(src)
        if not src or type(data) ~= 'table' then return end
        TriggerClientEvent('o-link:rcore:applyPersist', src, data, save == true)
        return data
    end,

    ---Persist a full canonical look (same live-ped snapshot path).
    ---@param src number
    ---@param data table
    ---@param save boolean|nil
    ---@return boolean
    SaveCreatorAppearance = function(src, data, save)
        src = tonumber(src)
        if not src or type(data) ~= 'table' then return false end
        TriggerClientEvent('o-link:rcore:applyPersist', src, data, save ~= false)
        return true
    end,

    SetAppearanceExt = function(src, data)
        local isMale = olink.clothing.IsMale(src)
        local tbl = isMale and data.male or data.female
        return olink.clothing.SetAppearance(src, tbl)
    end,

    OpenMenu = function(src)
        src = tonumber(src)
        if src then TriggerClientEvent('o-link:client:clothing:openMenu', src) end
    end,

    ---@param src number
    ---@return boolean
    IsMale = function(src)
        src = tonumber(src)
        if not src then return false end
        local _, pedModel = readOutfit(src)
        if pedModel ~= nil then
            return pedModel == `mp_m_freemode_01` or pedModel == 'mp_m_freemode_01'
        end
        local ped = GetPlayerPed(src)
        if not ped or not DoesEntityExist(ped) then return false end
        return GetEntityModel(ped) == `mp_m_freemode_01`
    end,

})
