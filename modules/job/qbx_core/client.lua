if GetResourceState('qbx_core') == 'missing' then return end

local QBox = exports.qbx_core

olink._register('job', {
    ---@return table|nil JobData { name, label, grade, gradeLabel, rank, isBoss, onDuty }
    Get = function()
        local playerData = QBox.GetPlayerData()
        if not playerData then
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
        local playerData = QBox.GetPlayerData()
        if not playerData then return false end
        return playerData.job.onduty or false
    end,
})
