if GetResourceState('fd_banking') ~= 'started' then return end

local fd_banking = exports['fd_banking']

olink._register('banking', {
    ---@return string
    GetManagmentName = function()
        return 'fd_banking'
    end,

    ---@return string
    GetResourceName = function()
        return 'fd_banking'
    end,

    ---@param account string
    ---@return number
    GetAccountMoney = function(account)
        return fd_banking:GetAccount(account)
    end,

    ---@param account string
    ---@param amount number
    ---@param reason string
    ---@return boolean
    AddAccountMoney = function(account, amount, reason)
        return fd_banking:AddMoney(account, amount, reason)
    end,

    ---@param account string
    ---@param amount number
    ---@param reason string
    ---@return boolean
    RemoveAccountMoney = function(account, amount, reason)
        return fd_banking:RemoveMoney(account, amount, reason)
    end,
})
