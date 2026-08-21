local RESOURCE = 'oxide-gangs'

if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Gang', RESOURCE, false) then return end

local res = exports[RESOURCE]

local function isStarted()
    return GetResourceState(RESOURCE) == 'started'
end

olink._register('gang', {
    ---@return string
    GetResourceName = function() return RESOURCE end,

    ---@param src number
    ---@return table|nil { name, label, grade, gradeLabel, rank }
    Get = function(src)
        if not isStarted() then return nil end
        local ok, result = pcall(function() return res:Get(src) end)
        return ok and result or nil
    end,

    ---@param src number
    ---@param gangName string|nil pass nil to remove the player from their gang
    ---@param gangLabel string|nil
    ---@param gradeName string|nil
    ---@param gradeLabel string|nil
    ---@param gradeRank number|nil
    ---@return boolean
    Set = function(src, gangName, gangLabel, gradeName, gradeLabel, gradeRank)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:Set(src, gangName, gangLabel, gradeName, gradeLabel, gradeRank) end)
        return ok and result == true
    end,

    ---@return table[] { id, name, label, color, motto, memberCount }
    GetAll = function()
        if not isStarted() then return {} end
        local ok, result = pcall(function() return res:GetAll() end)
        return ok and result or {}
    end,

    ---@param gangName string
    ---@return table[] { charId, name, rank, gradeLabel, online }
    GetMembers = function(gangName)
        if not isStarted() then return {} end
        local ok, result = pcall(function() return res:GetMembers(gangName) end)
        return ok and result or {}
    end,

    ---@param gangName string
    ---@return table[] { rank, name, label, isBoss, permissions }
    GetGrades = function(gangName)
        if not isStarted() then return {} end
        local ok, result = pcall(function() return res:GetGrades(gangName) end)
        return ok and result or {}
    end,

    ---@param src number
    ---@param perm string
    ---@return boolean
    HasPermission = function(src, perm)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:HasPermission(src, perm) end)
        return ok and result == true
    end,

    ---@param gangName string
    ---@param amount number
    ---@param description string|nil
    ---@return boolean
    AddToTreasury = function(gangName, amount, description)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:AddToTreasury(gangName, amount, description) end)
        return ok and result == true
    end,

    ---@param gangName string
    ---@param amount number
    ---@param description string|nil
    ---@return boolean
    RemoveFromTreasury = function(gangName, amount, description)
        if not isStarted() then return false end
        local ok, result = pcall(function() return res:RemoveFromTreasury(gangName, amount, description) end)
        return ok and result == true
    end,

    ---@param gangName string
    ---@return number
    GetTreasury = function(gangName)
        if not isStarted() then return 0 end
        local ok, result = pcall(function() return res:GetTreasury(gangName) end)
        return ok and tonumber(result) or 0
    end,

    ---@return table[] { id, name, label, color, center, owner?, contested, contestEndsAt?, modifiers?, standings }
    GetTerritories = function()
        if not isStarted() then return {} end
        local ok, result = pcall(function() return res:GetTerritories() end)
        return ok and result or {}
    end,

    ---@param x number|table coords table or x
    ---@return table|nil territory at the point, with owner + modifiers
    GetTerritoryAt = function(x, y, z)
        if not isStarted() then return nil end
        local ok, result = pcall(function() return res:GetTerritoryAt(x, y, z) end)
        return ok and result or nil
    end,

    ---@param territoryId number
    ---@return string|nil owning gang name
    GetTerritoryOwner = function(territoryId)
        if not isStarted() then return nil end
        local ok, result = pcall(function() return res:GetTerritoryOwner(territoryId) end)
        return ok and result or nil
    end,

    ---@param src number the seller
    ---@param coords table where the sale happened
    ---@param value number sale value in dollars
    ---@return number influence applied (0 when capped, gangless or outside territories)
    ReportDrugSale = function(src, coords, value)
        if not isStarted() then return 0 end
        local ok, result = pcall(function() return res:ReportDrugSale(src, coords, value) end)
        return ok and tonumber(result) or 0
    end,
}, RESOURCE)
