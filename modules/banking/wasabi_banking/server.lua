if GetResourceState('wasabi_banking') ~= 'started' then return end

local wasabi_banking = exports['wasabi_banking']

olink._register('banking', {
    ---@return string
    GetManagmentName = function()
        return 'wasabi_banking'
    end,

    ---@return string
    GetResourceName = function()
        return 'wasabi_banking'
    end,

    ---@param account string
    ---@return number
    GetAccountMoney = function(account)
        local balance = wasabi_banking:GetAccountBalance(account, 'society')
        return balance or 0
    end,

    ---@param account string
    ---@param amount number
    ---@param reason string
    ---@return boolean
    AddAccountMoney = function(account, amount, reason)
        return wasabi_banking:AddMoney('society', account, amount)
    end,

    ---@param account string
    ---@param amount number
    ---@param reason string
    ---@return boolean
    RemoveAccountMoney = function(account, amount, reason)
        return wasabi_banking:RemoveMoney('society', account, amount)
    end,
})
