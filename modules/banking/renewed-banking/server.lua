if GetResourceState('Renewed-Banking') ~= 'started' then return end

local renewed = exports['Renewed-Banking']

olink._register('banking', {
    ---@return string
    GetManagmentName = function()
        return 'Renewed-Banking'
    end,

    ---@return string
    GetResourceName = function()
        return 'Renewed-Banking'
    end,

    ---@param account string
    ---@return number
    GetAccountMoney = function(account)
        return renewed:getAccountMoney(account)
    end,

    ---@param account string
    ---@param amount number
    ---@param _ string
    ---@return boolean
    AddAccountMoney = function(account, amount, _)
        return renewed:addAccountMoney(account, amount)
    end,

    ---@param account string
    ---@param amount number
    ---@param _ string
    ---@return boolean
    RemoveAccountMoney = function(account, amount, _)
        return renewed:removeAccountMoney(account, amount)
    end,
})
