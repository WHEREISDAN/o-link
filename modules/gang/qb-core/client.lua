if not olink._guardImpl('Gang', 'qb-core', 'qb-core') then return end
if not olink._hasOverride('Gang') and GetResourceState('oxide-gangs') ~= 'missing' then return end
if not olink._hasOverride('Gang') and GetResourceState('qbx_core') == 'started' then return end
if not olink._hasOverride('Gang') and GetResourceState('oxide-core') == 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

olink._register('gang', {
    ---@return table|nil { name, label, grade, gradeLabel, rank }
    Get = function()
        local data = QBCore.Functions.GetPlayerData()
        if not data or not data.gang then return nil end
        local gang = data.gang
        if gang.name == 'none' then return nil end
        return {
            name       = gang.name,
            label      = gang.label or gang.name,
            grade      = gang.grade and gang.grade.name or 'default',
            gradeLabel = gang.grade and gang.grade.name or 'Default',
            rank       = gang.grade and gang.grade.level or 0,
        }
    end,
})
