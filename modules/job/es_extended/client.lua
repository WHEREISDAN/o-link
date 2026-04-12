if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

olink._register('job', {
    ---@return table|nil JobData { name, label, grade, gradeLabel, rank, isBoss, onDuty }
    Get = function()
        local playerData = ESX.GetPlayerData()
        if not playerData or not playerData.job then
            return { name = 'unemployed', label = 'Unemployed', grade = 'default', gradeLabel = 'Default', rank = 0, isBoss = false, onDuty = false }
        end
        local job = playerData.job
        return {
            name       = job.name or 'unemployed',
            label      = job.label or 'Unemployed',
            grade      = job.grade_name or 'default',
            gradeLabel = job.grade_label or 'Default',
            rank       = job.grade or 0,
            isBoss     = (job.grade_name == 'boss'),
            onDuty     = job.onduty or false,
        }
    end,

    ---@return boolean
    GetDuty = function()
        local playerData = ESX.GetPlayerData()
        if not playerData or not playerData.job then return false end
        return playerData.job.onduty or false
    end,
})
