if GetResourceState('es_extended') == 'missing' then return end

local ESX = exports['es_extended']:getSharedObject()

---@param src number
---@return table|nil xPlayer
local function GetPlayer(src)
    return ESX.GetPlayerFromId(src)
end

olink._register('job', {
    ---@param src number
    ---@return table|nil JobData { name, label, grade, gradeLabel, rank, isBoss, onDuty }
    Get = function(src)
        local xPlayer = GetPlayer(src)
        if not xPlayer then return nil end
        local job = xPlayer.getJob()
        if not job then return nil end
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

    ---@param src number
    ---@param jobName string
    ---@param grade string|number
    ---@return boolean
    Set = function(src, jobName, grade)
        local xPlayer = GetPlayer(src)
        if not xPlayer then return false end
        if not ESX.DoesJobExist(jobName, grade) then return false end
        xPlayer.setJob(jobName, grade, true)
        return true
    end,

    ---@param src number
    ---@param status boolean
    ---@return boolean
    -- ESX has no native duty toggle — approximated via setJob with duty flag
    SetDuty = function(src, status)
        local xPlayer = GetPlayer(src)
        if not xPlayer then return false end
        local job = xPlayer.getJob()
        if not job or job.name == 'unemployed' then return false end
        xPlayer.setJob(job.name, job.grade, status)
        return true
    end,

    ---@param src number
    ---@return boolean
    GetDuty = function(src)
        local xPlayer = GetPlayer(src)
        if not xPlayer then return false end
        local job = xPlayer.getJob()
        if not job then return false end
        return job.onduty or false
    end,

    ---@param jobName string
    ---@return number[]
    GetPlayersWithJob = function(jobName)
        local players = ESX.GetExtendedPlayers('job', jobName)
        local list = {}
        for _, xPlayer in pairs(players) do
            list[#list + 1] = xPlayer.source
        end
        return list
    end,
})
