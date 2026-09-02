if not olink._guardImpl('Banking', 'qb-banking', 'qb-banking') then return end

local qbBanking = exports['qb-banking']

olink._register('banking', {
    ---@return string
    GetManagmentName = function()
        return 'qb-banking'
    end,

    ---@return string
    GetResourceName = function()
        return 'qb-banking'
    end,

    ---@param account string
    ---@return number
    GetAccountMoney = function(account)
        return qbBanking:GetAccountBalance(account)
    end,

    ---@param account string
    ---@param amount number
    ---@param reason string
    ---@return boolean
    AddAccountMoney = function(account, amount, reason)
        return qbBanking:AddMoney(account, amount, reason)
    end,

    ---@param account string
    ---@param amount number
    ---@param reason string
    ---@return boolean
    RemoveAccountMoney = function(account, amount, reason)
        return qbBanking:RemoveMoney(account, amount, reason)
    end,

    ---@param accountName string
    ---@param balance number|nil
    ---@return boolean created false when the account already exists
    CreateJobAccount = function(accountName, balance)
        if qbBanking:GetAccount(accountName) then return false end

        -- qb-banking's CreateJobAccount never checks for an existing account: it
        -- overwrites the cached balance and inserts a second row. Its own account
        -- cache loads asynchronously at boot, so a caller arriving first would see
        -- no account and reset a live treasury. Fall back to the table.
        local existing = MySQL.single.await(
            'SELECT id FROM bank_accounts WHERE account_name = ? AND account_type = ?',
            { accountName, 'job' }
        )
        if existing then return false end

        return qbBanking:CreateJobAccount(accountName, balance or 0) and true or false
    end,
})
