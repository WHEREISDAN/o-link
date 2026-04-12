if GetResourceState('okokBanking') ~= 'started' then return end

local okokBanking = exports['okokBanking']

olink._register('banking', {
    ---@return string
    GetManagmentName = function()
        return 'okokBanking'
    end,

    ---@return string
    GetResourceName = function()
        return 'okokBanking'
    end,

    ---@param account string
    ---@return number
    GetAccountMoney = function(account)
        return okokBanking:GetAccount(account)
    end,

    ---@param account string
    ---@param amount number
    ---@param _ string
    ---@return boolean
    AddAccountMoney = function(account, amount, _)
        return okokBanking:AddMoney(account, amount)
    end,

    ---@param account string
    ---@param amount number
    ---@param _ string
    ---@return boolean
    RemoveAccountMoney = function(account, amount, _)
        return okokBanking:RemoveMoney(account, amount)
    end,
})
