if not olink._guardImpl('License', 'oxide-core', 'oxide-core') then return end

local Oxide = exports['oxide-core']:Core()

local function GetChar(src)
    local player = Oxide.Functions.GetPlayer(src)
    if not player then return nil end
    return player.GetCharacter()
end

-- Shallow-copy: oxide-core's SetMetadata short-circuits on reference equality,
-- suppressing the write if the live table is mutated in place.
local function GetLicensesOnline(src)
    local char = GetChar(src)
    if not char then return nil end
    local copy = {}
    for k, v in pairs(char.GetMetadata('licenses') or {}) do copy[k] = v end
    return copy
end

-- Force a save: oxide-core's SetMetadata is in-memory only.
local function WriteLicensesOnline(src, licenses)
    local char = GetChar(src)
    if not char then return false end
    char.SetMetadata('licenses', licenses)
    Oxide.Functions.SaveCharacter(char)
    return true
end

-- state_id is the user-facing identifier; fall back to char_id for numeric ids.
local function MutateOffline(identifier, licenseType, granted)
    local affected = MySQL.update.await(
        'UPDATE characters SET metadata = JSON_SET(metadata, ?, ?) WHERE state_id = ? AND deleted_at IS NULL',
        { '$.licenses.' .. licenseType, granted, identifier }
    )
    if (not affected or affected == 0) and tonumber(identifier) then
        affected = MySQL.update.await(
            'UPDATE characters SET metadata = JSON_SET(metadata, ?, ?) WHERE char_id = ? AND deleted_at IS NULL',
            { '$.licenses.' .. licenseType, granted, tonumber(identifier) }
        )
    end
    return affected and affected > 0
end

local function ReadOffline(identifier)
    local raw = MySQL.scalar.await(
        'SELECT JSON_EXTRACT(metadata, ?) FROM characters WHERE state_id = ? AND deleted_at IS NULL',
        { '$.licenses', identifier }
    )
    if not raw and tonumber(identifier) then
        raw = MySQL.scalar.await(
            'SELECT JSON_EXTRACT(metadata, ?) FROM characters WHERE char_id = ? AND deleted_at IS NULL',
            { '$.licenses', tonumber(identifier) }
        )
    end
    if not raw then return {} end
    local decoded = type(raw) == 'string' and json.decode(raw) or raw
    return type(decoded) == 'table' and decoded or {}
end

olink._register('license', {
    ---@param src number
    ---@param licenseType string
    ---@return boolean
    Has = function(src, licenseType)
        local l = GetLicensesOnline(src)
        return l and l[licenseType] == true or false
    end,

    ---@param src number
    ---@param licenseType string
    ---@return boolean
    Grant = function(src, licenseType)
        local l = GetLicensesOnline(src)
        if not l then return false end
        l[licenseType] = true
        return WriteLicensesOnline(src, l)
    end,

    ---@param src number
    ---@param licenseType string
    ---@return boolean
    Revoke = function(src, licenseType)
        local l = GetLicensesOnline(src)
        if not l then return false end
        l[licenseType] = false
        return WriteLicensesOnline(src, l)
    end,

    ---@param src number
    ---@return table
    GetAll = function(src)
        return GetLicensesOnline(src) or {}
    end,

    ---@param identifier string state_id or char_id
    ---@param licenseType string
    ---@return boolean
    HasOffline = function(identifier, licenseType)
        local l = ReadOffline(identifier)
        return l[licenseType] == true
    end,

    ---@param identifier string state_id or char_id
    ---@param licenseType string
    ---@return boolean
    GrantOffline = function(identifier, licenseType)
        return MutateOffline(identifier, licenseType, true)
    end,

    ---@param identifier string state_id or char_id
    ---@param licenseType string
    ---@return boolean
    RevokeOffline = function(identifier, licenseType)
        return MutateOffline(identifier, licenseType, false)
    end,

    ---@param identifier string state_id or char_id
    ---@return table
    GetAllOffline = function(identifier)
        return ReadOffline(identifier)
    end,
})
