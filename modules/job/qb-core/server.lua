if GetResourceState('qb-core') ~= 'started' then return end
if GetResourceState('qbx_core') == 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

---@param src number
---@return table|nil
local function GetPlayer(src)
    return QBCore.Functions.GetPlayer(src)
end

olink._register('job', {
    ---@param src number
    ---@return table|nil JobData { name, label, grade, gradeLabel, rank, isBoss, onDuty }
    Get = function(src)
        local player = GetPlayer(src)
        if not player then return nil end
        local job = player.PlayerData.job
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

    ---@param src number
    ---@param jobName string
    ---@param grade string|number
    ---@return boolean
    Set = function(src, jobName, grade)
        local player = GetPlayer(src)
        if not player then return false end
        return player.Functions.SetJob(jobName, grade) or true
    end,

    ---@param src number
    ---@param status boolean
    ---@return boolean
    SetDuty = function(src, status)
        local player = GetPlayer(src)
        if not player then return false end
        player.Functions.SetJobDuty(status)
        TriggerEvent('QBCore:Server:SetDuty', src, status)
        return true
    end,

    ---@param src number
    ---@return boolean
    GetDuty = function(src)
        local player = GetPlayer(src)
        if not player then return false end
        return player.PlayerData.job.onduty or false
    end,

    ---@param jobName string
    ---@return number[]
    GetPlayersWithJob = function(jobName)
        local result = {}
        local players = QBCore.Functions.GetPlayers()
        for _, src in pairs(players) do
            local player = QBCore.Functions.GetPlayer(src)
            if player and player.PlayerData.job.name == jobName then
                result[#result + 1] = src
            end
        end
        return result
    end,
})
