if GetResourceState('tgg-banking') == 'missing' then return end

local tgg = exports['tgg-banking']

olink._register('banking', {
    ---@return string
    GetManagmentName = function()
        return 'tgg-banking'
    end,

    ---@return string
    GetResourceName = function()
        return 'tgg-banking'
    end,

    ---@param account string
    ---@return number
    GetAccountMoney = function(account)
        return tgg:GetSocietyAccountMoney(account) or 0
    end,

    ---@param account string
    ---@param amount number
    ---@param _ string
    ---@return boolean
    AddAccountMoney = function(account, amount, _)
        return tgg:AddSocietyMoney(account, amount)
    end,

    ---@param account string
    ---@param amount number
    ---@param _ string
    ---@return boolean
    RemoveAccountMoney = function(account, amount, _)
        return tgg:RemoveSocietyMoney(account, amount)
    end,
})
