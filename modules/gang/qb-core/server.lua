if not olink._guardImpl('Gang', 'qb-core', 'qb-core') then return end
if not olink._hasOverride('Gang') and GetResourceState('oxide-gangs') ~= 'missing' then return end
if not olink._hasOverride('Gang') and GetResourceState('qbx_core') == 'started' then return end
if not olink._hasOverride('Gang') and GetResourceState('oxide-core') == 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

olink._register('gang', {
    ---@param src number
    ---@return table|nil { name, label, grade, gradeLabel, rank }
    Get = function(src)
        local p = QBCore.Functions.GetPlayer(src)
        if not p then return nil end
        local gang = p.PlayerData.gang
        if not gang or gang.name == 'none' then return nil end
        return {
            name       = gang.name,
            label      = gang.label or gang.name,
            grade      = gang.grade and gang.grade.name or 'default',
            gradeLabel = gang.grade and gang.grade.name or 'Default',
            rank       = gang.grade and gang.grade.level or 0,
        }
    end,

    ---@param src number
    ---@param gangName string|nil
    ---@param gangLabel string|nil
    ---@param gradeName string|nil
    ---@param gradeLabel string|nil
    ---@param gradeRank number|nil
    ---@return boolean
    Set = function(src, gangName, gangLabel, gradeName, gradeLabel, gradeRank)
        local p = QBCore.Functions.GetPlayer(src)
        if not p then return false end
        p.Functions.SetGang(gangName or 'none', gradeRank or 0)
        return true
    end,
})
