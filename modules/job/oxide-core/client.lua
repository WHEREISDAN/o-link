if GetResourceState('oxide-core') ~= 'started' then return end

olink._register('job', {
    ---@return table|nil JobData { name, label, grade, gradeLabel, rank, isBoss, onDuty }
    Get = function()
        local job = LocalPlayer.state['oxide:job']
        if not job then
            return { name = 'unemployed', label = 'Unemployed', grade = 'default', gradeLabel = 'Default', rank = 0, isBoss = false, onDuty = false }
        end
        return {
            name       = job.jobName or 'unemployed',
            label      = job.jobLabel or 'Unemployed',
            grade      = job.gradeName or 'default',
            gradeLabel = job.gradeLabel or 'Default',
            rank       = job.gradeRank or 0,
            isBoss     = job.boss or false,
            onDuty     = job.onDuty or false,
        }
    end,

    ---@return boolean
    GetDuty = function()
        local job = LocalPlayer.state['oxide:job']
        return job and job.onDuty or false
    end,
})
