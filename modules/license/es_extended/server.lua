if not olink._guardImpl('License', 'es_extended', 'es_extended') then return end

-- esx_license events require an online source and removeLicense is job-gated.
-- Going direct to user_licenses bypasses both — the caller handles authz.
-- License types should exist in the `licenses` table for ESX UIs to label them.

local ESX = exports['es_extended']:getSharedObject()

local function GetIdentifier(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return nil end
    return xPlayer.getIdentifier()
end

local function HasOffline(identifier, licenceType)
    local result = MySQL.scalar.await(
        'SELECT 1 FROM user_licenses WHERE owner = ? AND type = ?',
        { identifier, licenceType }
    )
    return result ~= nil
end

local function GrantOffline(identifier, licenceType)
    if HasOffline(identifier, licenceType) then return true end
    local id = MySQL.insert.await(
        'INSERT INTO user_licenses (type, owner) VALUES (?, ?)',
        { licenceType, identifier }
    )
    return id and id > 0
end

local function RevokeOffline(identifier, licenceType)
    local affected = MySQL.update.await(
        'DELETE FROM user_licenses WHERE owner = ? AND type = ?',
        { identifier, licenceType }
    )
    return affected and affected > 0
end

local function GetAllOffline(identifier)
    local rows = MySQL.query.await(
        'SELECT type FROM user_licenses WHERE owner = ?',
        { identifier }
    )
    local out = {}
    for _, row in ipairs(rows or {}) do out[row.type] = true end
    return out
end

olink._register('license', {
    ---@param src number
    ---@param licenceType string
    ---@return boolean
    Has = function(src, licenceType)
        local identifier = GetIdentifier(src)
        if not identifier then return false end
        return HasOffline(identifier, licenceType)
    end,

    ---@param src number
    ---@param licenceType string
    ---@return boolean
    Grant = function(src, licenceType)
        local identifier = GetIdentifier(src)
        if not identifier then return false end
        return GrantOffline(identifier, licenceType)
    end,

    ---@param src number
    ---@param licenceType string
    ---@return boolean
    Revoke = function(src, licenceType)
        local identifier = GetIdentifier(src)
        if not identifier then return false end
        return RevokeOffline(identifier, licenceType)
    end,

    ---@param src number
    ---@return table
    GetAll = function(src)
        local identifier = GetIdentifier(src)
        if not identifier then return {} end
        return GetAllOffline(identifier)
    end,

    ---@param identifier string esx identifier
    ---@param licenceType string
    ---@return boolean
    HasOffline = HasOffline,

    ---@param identifier string esx identifier
    ---@param licenceType string
    ---@return boolean
    GrantOffline = GrantOffline,

    ---@param identifier string esx identifier
    ---@param licenceType string
    ---@return boolean
    RevokeOffline = RevokeOffline,

    ---@param identifier string esx identifier
    ---@return table
    GetAllOffline = GetAllOffline,
})
