if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

---@param src number
---@return table|nil xPlayer
local function GetPlayer(src)
    return ESX.GetPlayerFromId(src)
end

---Normalize account type: o-link uses 'cash', ESX uses 'money'
---@param accountType string
---@return string
local function NormalizeType(accountType)
    if accountType == 'cash' then return 'money' end
    return accountType
end

olink._register('money', {
    ---@param src number
    ---@param accountType string 'cash'|'bank'
    ---@param amount number
    ---@return boolean
    Add = function(src, accountType, amount, reason)
        if amount <= 0 then return false end
        local xPlayer = GetPlayer(src)
        if not xPlayer then return false end
        xPlayer.addAccountMoney(NormalizeType(accountType), amount, reason)
        return true
    end,

    ---@param src number
    ---@param accountType string 'cash'|'bank'
    ---@param amount number
    ---@param reason string|nil
    ---@return boolean
    Remove = function(src, accountType, amount, reason)
        if amount <= 0 then return false end
        local xPlayer = GetPlayer(src)
        if not xPlayer then return false end
        local esxType = NormalizeType(accountType)
        local account = xPlayer.getAccount(esxType)
        if not account or account.money < amount then return false end
        xPlayer.removeAccountMoney(esxType, amount, reason)
        return true
    end,

    ---@param src number
    ---@param accountType string 'cash'|'bank'
    ---@return number
    GetBalance = function(src, accountType)
        local xPlayer = GetPlayer(src)
        if not xPlayer then return 0 end
        local account = xPlayer.getAccount(NormalizeType(accountType))
        if not account then return 0 end
        return account.money or 0
    end,

    ---@param identifier string ESX identifier
    ---@param accountType string 'cash'|'bank'
    ---@param amount number
    ---@return boolean
    AddOffline = function(identifier, accountType, amount)
        if amount <= 0 then return false end
        local esxType = NormalizeType(accountType)
        local row = MySQL.single.await('SELECT accounts FROM users WHERE identifier = ?', { identifier })
        if not row or not row.accounts then return false end
        local accounts = json.decode(row.accounts)
        if not accounts then return false end
        for _, acc in ipairs(accounts) do
            if acc.name == esxType then
                acc.money = (acc.money or 0) + amount
                MySQL.update.await('UPDATE users SET accounts = ? WHERE identifier = ?', { json.encode(accounts), identifier })
                return true
            end
        end
        return false
    end,

    ---@param identifier string ESX identifier
    ---@param accountType string 'cash'|'bank'
    ---@param amount number
    ---@return boolean
    RemoveOffline = function(identifier, accountType, amount)
        if amount <= 0 then return false end
        local esxType = NormalizeType(accountType)
        local row = MySQL.single.await('SELECT accounts FROM users WHERE identifier = ?', { identifier })
        if not row or not row.accounts then return false end
        local accounts = json.decode(row.accounts)
        if not accounts then return false end
        for _, acc in ipairs(accounts) do
            if acc.name == esxType then
                if (acc.money or 0) < amount then return false end
                acc.money = acc.money - amount
                MySQL.update.await('UPDATE users SET accounts = ? WHERE identifier = ?', { json.encode(accounts), identifier })
                return true
            end
        end
        return false
    end,

    ---@param identifier string ESX identifier
    ---@param accountType string 'cash'|'bank'
    ---@return number
    GetBalanceOffline = function(identifier, accountType)
        local esxType = NormalizeType(accountType)
        local row = MySQL.single.await('SELECT accounts FROM users WHERE identifier = ?', { identifier })
        if not row or not row.accounts then return 0 end
        local accounts = json.decode(row.accounts)
        if not accounts then return 0 end
        for _, acc in ipairs(accounts) do
            if acc.name == esxType then
                return acc.money or 0
            end
        end
        return 0
    end,
})
