-- Adapter for oxide-banking. Registers IMMEDIATELY so that consumers which
-- snapshot olink across the resource boundary capture the real wrapper
-- functions, not the defaults_server stubs. Wrappers gate on the resource
-- being started at call time. See .claude/rules/community-bridge-usage.md.

local RESOURCE = 'oxide-banking'

-- Pure adapter: bail if the resource isn't installed at all so other adapters
-- (qb-banking, renewed-banking, _default fallback, etc.) own the namespace.
if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Banking', RESOURCE, false) then return end

local res = exports[RESOURCE]

local function isStarted()
    return GetResourceState(RESOURCE) == 'started'
end

local function isReady()
    if not isStarted() then return false end
    local ok, ready = pcall(function() return res:IsReady() end)
    return ok and ready == true
end

olink._register('banking', {
    ---@return string
    GetResourceName = function() return RESOURCE end,

    ---qb-banking compat surface (consumers query this for the active banking impl).
    ---@return string
    GetManagmentName = function() return RESOURCE end,

    ---@return boolean
    IsReady = function()
        return isReady()
    end,

    -- =========================================================
    -- Read-side: gate on IsReady() so callers during the 1-5s
    -- DB-load window get safe defaults instead of partial reads.
    -- =========================================================

    ---@param accountName string
    ---@return number
    GetBalance = function(accountName)
        if not isReady() then return 0 end
        local ok, result = pcall(function() return res:GetAccountBalance(accountName) end)
        return (ok and tonumber(result)) or 0
    end,

    ---@param accountName string
    ---@return table|nil
    GetAccount = function(accountName)
        if not isReady() then return nil end
        local ok, result = pcall(function() return res:GetAccount(accountName) end)
        return ok and result or nil
    end,

    ---@param citizenid string
    ---@return number
    GetCreditScore = function(citizenid)
        if not isReady() then return 600 end
        local ok, result = pcall(function() return res:GetCreditScore(citizenid) end)
        return (ok and tonumber(result)) or 600
    end,

    ---@param citizenid string
    ---@param amount number
    ---@param accountName string|nil
    ---@return boolean
    CanAfford = function(citizenid, amount, accountName)
        if not isReady() then return false end
        local ok, result = pcall(function() return res:CanAfford(citizenid, amount, accountName) end)
        return ok and result == true
    end,

    ---@param citizenid string
    ---@return table[]
    GetPlayerAccounts = function(citizenid)
        if not isReady() then return {} end
        local ok, result = pcall(function() return res:GetPlayerAccounts(citizenid) end)
        return ok and result or {}
    end,

    ---@param citizenid string
    ---@return table|nil
    GetPlayerBankingData = function(citizenid)
        if not isReady() then return nil end
        local ok, result = pcall(function() return res:GetPlayerBankingData(citizenid) end)
        return ok and result or nil
    end,

    -- =========================================================
    -- Write-side: oxide-banking's exports already guard against
    -- early calls — let them surface their own failure signal.
    -- =========================================================

    ---@param accountName string
    ---@param amount number
    ---@param reason string|nil
    ---@return boolean
    AddMoney = function(accountName, amount, reason)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:AddMoney(accountName, amount, reason) end)
        return ok and result == true
    end,

    ---@param accountName string
    ---@param amount number
    ---@param reason string|nil
    ---@return boolean
    RemoveMoney = function(accountName, amount, reason)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:RemoveMoney(accountName, amount, reason) end)
        return ok and result == true
    end,

    ---@param playerId number|string citizenid
    ---@param accountName string
    ---@param balance number|nil
    ---@param users table|nil
    ---@return boolean
    CreatePlayerAccount = function(playerId, accountName, balance, users)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:CreatePlayerAccount(playerId, accountName, balance, users) end)
        return ok and result == true
    end,

    ---@param accountName string
    ---@param balance number|nil
    ---@return boolean
    CreateJobAccount = function(accountName, balance)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:CreateJobAccount(accountName, balance) end)
        return ok and result == true
    end,
}, RESOURCE)
