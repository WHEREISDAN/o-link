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

    ---@param src number
    ---@return table|nil
    GetRecord = function(src)
        if not isStarted() then return nil end
        local ok, result = pcall(function() return res:GetRecord(src) end)
        return ok and result or nil
    end,

    ---@param src number
    ---@return string|nil
    GetBloodType = function(src)
        if not isStarted() then return nil end
        local ok, result = pcall(function() return res:GetBloodType(src) end)
        return ok and result or nil
    end,

    ---@param src number
    ---@return string|nil
    GetDNA = function(src)
        if not isStarted() then return nil end
        local ok, result = pcall(function() return res:GetDNA(src) end)
        return ok and result or nil
    end,

    ---@param src number
    ---@return number
    GetImmunity = function(src)
        if not isStarted() then return 100 end
        local ok, result = pcall(function() return res:GetImmunity(src) end)
        return (ok and result) or 100
    end,

    ---@param src number
    ---@return table[]
    GetConditions = function(src)
        if not isStarted() then return {} end
        local ok, result = pcall(function() return res:GetConditions(src) end)
        return ok and result or {}
    end,

    ---@param src number
    ---@param typeOrCategory string
    ---@return boolean
    HasCondition = function(src, typeOrCategory)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:HasCondition(src, typeOrCategory) end)
        return ok and result == true
    end,

    ---@param src number
    ---@param payload table { category, type, bodypart?, severity?, expiresInSec?, data? }
    ---@return number|false id
    AddCondition = function(src, payload)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:AddCondition(src, payload) end)
        return (ok and result) or false
    end,

    ---@param src number
    ---@param idOrType number|string
    ---@param treaterSrc number|nil
    ---@return boolean
    TreatCondition = function(src, idOrType, treaterSrc)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:TreatCondition(src, idOrType, treaterSrc) end)
        return ok and result == true
    end,

    ---@param src number
    ---@param idOrType number|string
    ---@return boolean
    RemoveCondition = function(src, idOrType)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:RemoveCondition(src, idOrType) end)
        return ok and result == true
    end,

    ---@param charId string
    ---@return table|nil { record, conditions }
    GetOfflineRecord = function(charId)
        if not isStarted() then return nil end
        local ok, result = pcall(function() return res:GetOfflineRecord(charId) end)
        return ok and result or nil
    end,
}, RESOURCE)
