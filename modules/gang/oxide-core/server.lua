if not olink._guardImpl('Gang', 'oxide-core', 'oxide-core') then return end
if not olink._hasOverride('Gang') and GetResourceState('oxide-gangs') ~= 'missing' then return end

local Oxide = exports['oxide-core']:Core()

local function GetChar(src)
    local player = Oxide.Functions.GetPlayer(src)
    if not player then return nil end
    return player.GetCharacter()
end

olink._register('gang', {
    ---@param src number
    ---@return table|nil { name, label, grade, gradeLabel, rank }
    Get = function(src)
        local char = GetChar(src)
        if not char then return nil end
        local org = char.GetOrganization()
        if not org or not org.orgName then return nil end
        return {
            name       = org.orgName,
            label      = org.orgLabel or org.orgName,
            grade      = org.gradeName or 'default',
            gradeLabel = org.gradeLabel or 'Default',
            rank       = org.gradeRank or 0,
        }
    end,

    ---@param src number
    ---@param orgName string|nil pass nil to clear
    ---@param orgLabel string|nil
    ---@param gradeName string|nil
    ---@param gradeLabel string|nil
    ---@param gradeRank number|nil
    ---@return boolean
    Set = function(src, orgName, orgLabel, gradeName, gradeLabel, gradeRank)
        local char = GetChar(src)
        if not char then return false end
        char.SetOrganization(orgName, orgLabel, gradeName, gradeLabel, gradeRank)
        return true
    end,
})
