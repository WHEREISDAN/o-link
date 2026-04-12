if GetResourceState('qbx_core') ~= 'started' then return end

local QBox = exports.qbx_core

---@param src number
---@return table|nil
local function GetPlayer(src)
    return QBox:GetPlayer(src)
end

---Normalize account type names across frameworks
---@param accountType string
---@return string
local function NormalizeType(accountType)
    if accountType == 'money' then return 'cash' end
    return accountType
end

olink._register('money', {
    ---@param src number
    ---@param accountType string 'cash'|'bank'
    ---@param amount number
    ---@return boolean
    Add = function(src, accountType, amount, reason)
        if amount <= 0 then return false end
        local player = GetPlayer(src)
        if not player then return false end
        return player.Functions.AddMoney(NormalizeType(accountType), amount, reason) or true
    end,

    ---@param src number
    ---@param accountType string 'cash'|'bank'
    ---@param amount number
    ---@param reason string|nil
    ---@return boolean
    Remove = function(src, accountType, amount, reason)
        if amount <= 0 then return false end
        local player = GetPlayer(src)
        if not player then return false end
        return player.Functions.RemoveMoney(NormalizeType(accountType), amount, reason) or true
    end,

    ---@param src number
    ---@param accountType string 'cash'|'bank'
    ---@return number
    GetBalance = function(src, accountType)
        local player = GetPlayer(src)
        if not player then return 0 end
        return player.PlayerData.money[NormalizeType(accountType)] or 0
    end,

    ---@param identifier string citizenid
    ---@param accountType string 'cash'|'bank'
    ---@param amount number
    ---@return boolean
    AddOffline = function(identifier, accountType, amount)
        if amount <= 0 then return false end
        local key = '$.' .. NormalizeType(accountType)
        local affected = MySQL.update.await(
            'UPDATE players SET money = JSON_SET(money, ?, CAST(JSON_EXTRACT(money, ?) AS DECIMAL(15,2)) + ?) WHERE citizenid = ?',
            { key, key, amount, identifier }
        )
        return affected and affected > 0
    end,

    ---@param identifier string citizenid
    ---@param accountType string 'cash'|'bank'
    ---@param amount number
    ---@return boolean
    RemoveOffline = function(identifier, accountType, amount)
        if amount <= 0 then return false end
        local key = '$.' .. NormalizeType(accountType)
        local affected = MySQL.update.await(
            'UPDATE players SET money = JSON_SET(money, ?, CAST(JSON_EXTRACT(money, ?) AS DECIMAL(15,2)) - ?) WHERE citizenid = ? AND CAST(JSON_EXTRACT(money, ?) AS DECIMAL(15,2)) >= ?',
            { key, key, amount, identifier, key, amount }
        )
        return affected and affected > 0
    end,

    ---@param identifier string citizenid
    ---@param accountType string 'cash'|'bank'
    ---@return number
    GetBalanceOffline = function(identifier, accountType)
        local key = '$.' .. NormalizeType(accountType)
        local result = MySQL.scalar.await(
            'SELECT JSON_EXTRACT(money, ?) FROM players WHERE citizenid = ?',
            { key, identifier }
        )
        return tonumber(result) or 0
    end,
})
