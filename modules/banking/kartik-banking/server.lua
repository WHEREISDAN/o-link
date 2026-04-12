if GetResourceState('kartik-banking') == 'missing' then return end

local kartik = exports['kartik-banking']

olink._register('banking', {
    ---@return string
    GetManagmentName = function()
        return 'kartik-banking'
    end,

    ---@return string
    GetResourceName = function()
        return 'kartik-banking'
    end,

    ---@param account string
    ---@return number
    GetAccountMoney = function(account)
        local balance = kartik:GetAccountMoney(account)
        return balance or 0
    end,

    ---@param account string
    ---@param amount number
    ---@param reason string
    ---@return boolean
    AddAccountMoney = function(account, amount, reason)
        return kartik:AddAccountMoney(account, amount, reason)
    end,

    ---@param account string
    ---@param amount number
    ---@param reason string
    ---@return boolean
    RemoveAccountMoney = function(account, amount, reason)
        return kartik:RemoveAccountMoney(account, amount, reason)
    end,
})
