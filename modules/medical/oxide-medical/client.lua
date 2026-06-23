local RESOURCE = 'oxide-medical'

if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Medical', RESOURCE, false) then return end

local res = exports[RESOURCE]

local function isStarted()
    return GetResourceState(RESOURCE) == 'started'
end

olink._register('medical', {
    ---@return string
    GetResourceName = function() return RESOURCE end,

    ---@return table[]
    GetConditions = function()
        if not isStarted() then return {} end
        local ok, result = pcall(function() return res:GetConditions() end)
        return ok and result or {}
    end,

    ---@return boolean
    IsInjured = function()
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:IsInjured() end)
        return ok and result == true
    end,
}, RESOURCE)
