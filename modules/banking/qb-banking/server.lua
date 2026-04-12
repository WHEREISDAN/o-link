if GetResourceState('qb-banking') == 'missing' then return end

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
})
