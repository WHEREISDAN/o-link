if GetResourceState('tgiann-bank') ~= 'started' then return end

local tgiann = exports['tgiann-bank']

olink._register('banking', {
    ---@return string
    GetManagmentName = function()
        return 'tgiann-bank'
    end,

    ---@return string
    GetResourceName = function()
        return 'tgiann-bank'
    end,

    ---@param account string
    ---@return number
    GetAccountMoney = function(account)
        return tgiann:GetJobAccountBalance(account)
    end,

    ---@param account string
    ---@param amount number
    ---@param _ string
    ---@return boolean
    AddAccountMoney = function(account, amount, _)
        return tgiann:AddJobMoney(account, amount)
    end,

    ---@param account string
    ---@param amount number
    ---@param _ string
    ---@return boolean
    RemoveAccountMoney = function(account, amount, _)
        return tgiann:RemoveJobMoney(account, amount)
    end,
})
