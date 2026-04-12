if GetResourceState('qb-core') ~= 'started' then return end
if GetResourceState('qbx_core') == 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

olink._register('job', {
    ---@return table|nil JobData { name, label, grade, gradeLabel, rank, isBoss, onDuty }
    Get = function()
        local playerData = QBCore.Functions.GetPlayerData()
        if not playerData or not playerData.job then
            return { name = 'unemployed', label = 'Unemployed', grade = 'default', gradeLabel = 'Default', rank = 0, isBoss = false, onDuty = false }
        end
        local job = playerData.job
        return {
            name       = job.name or 'unemployed',
            label      = job.label or 'Unemployed',
            grade      = job.grade.name or 'default',
            gradeLabel = job.grade.name or 'Default',
            rank       = job.grade.level or 0,
            isBoss     = job.isboss or false,
            onDuty     = job.onduty or false,
        }
    end,

    ---@return boolean
    GetDuty = function()
        local playerData = QBCore.Functions.GetPlayerData()
        if not playerData or not playerData.job then return false end
        return playerData.job.onduty or false
    end,
})
