if not olink._guardImpl('License', 'qbx_core', 'qbx_core') then return end

local QBox = exports.qbx_core

local function GetPlayer(src)
    return QBox:GetPlayer(src)
end

-- Shallow-copy: some SetMetaData implementations short-circuit on reference
-- equality, suppressing the write if the live table is mutated in place.
local function GetLicences(src)
    local player = GetPlayer(src)
    if not player then return nil end
    local copy = {}
    for k, v in pairs(player.PlayerData.metadata.licences or {}) do copy[k] = v end
    return copy
end

-- Force a save: QBX's SetMetaData is in-memory only.
local function WriteLicences(src, licences)
    local player = GetPlayer(src)
    if not player then return false end
    player.Functions.SetMetaData('licences', licences)
    player.Functions.Save()
    return true
end

local function MutateOffline(identifier, licenceType, granted)
    local affected = MySQL.update.await(
        'UPDATE players SET metadata = JSON_SET(metadata, ?, ?) WHERE citizenid = ?',
        { '$.licences.' .. licenceType, granted, identifier }
    )
    return affected and affected > 0
end

olink._register('license', {
    ---@param src number
    ---@param licenceType string
    ---@return boolean
    Has = function(src, licenceType)
        local l = GetLicences(src)
        return l and l[licenceType] == true or false
    end,

    ---@param src number
    ---@param licenceType string
    ---@return boolean
    Grant = function(src, licenceType)
        local l = GetLicences(src)
        if not l then return false end
        l[licenceType] = true
        return WriteLicences(src, l)
    end,

    ---@param src number
    ---@param licenceType string
    ---@return boolean
    Revoke = function(src, licenceType)
        local l = GetLicences(src)
        if not l then return false end
        l[licenceType] = false
        return WriteLicences(src, l)
    end,

    ---@param src number
    ---@return table
    GetAll = function(src)
        return GetLicences(src) or {}
    end,

    ---@param identifier string citizenid
    ---@param licenceType string
    ---@return boolean
    HasOffline = function(identifier, licenceType)
        local result = MySQL.scalar.await(
            'SELECT JSON_EXTRACT(metadata, ?) FROM players WHERE citizenid = ?',
            { '$.licences.' .. licenceType, identifier }
        )
        return result == 1 or result == true or result == 'true'
    end,

    ---@param identifier string citizenid
    ---@param licenceType string
    ---@return boolean
    GrantOffline = function(identifier, licenceType)
        return MutateOffline(identifier, licenceType, true)
    end,

    ---@param identifier string citizenid
    ---@param licenceType string
    ---@return boolean
    RevokeOffline = function(identifier, licenceType)
        return MutateOffline(identifier, licenceType, false)
    end,

    ---@param identifier string citizenid
    ---@return table
    GetAllOffline = function(identifier)
        local raw = MySQL.scalar.await(
            'SELECT JSON_EXTRACT(metadata, ?) FROM players WHERE citizenid = ?',
            { '$.licences', identifier }
        )
        if not raw then return {} end
        local decoded = type(raw) == 'string' and json.decode(raw) or raw
        return type(decoded) == 'table' and decoded or {}
    end,
})
