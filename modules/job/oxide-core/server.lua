if GetResourceState('oxide-core') ~= 'started' then return end

local Oxide = exports['oxide-core']:Core()

---@param src number
---@return table|nil character
local function GetChar(src)
    local player = Oxide.Functions.GetPlayer(src)
    if not player then return nil end
    return player.GetCharacter()
end

olink._register('job', {
    ---@param src number
    ---@return table|nil JobData { name, label, grade, gradeLabel, rank, isBoss, onDuty }
    Get = function(src)
        local char = GetChar(src)
        if not char then return nil end
        local job = char.GetJob()
        if not job then return nil end
        return {
            name       = job.jobName or 'unemployed',
            label      = job.jobLabel or 'Unemployed',
            grade      = job.gradeName or 'default',
            gradeLabel = job.gradeLabel or 'Default',
            rank       = job.gradeRank or 0,
            isBoss     = char.IsBoss(),
            onDuty     = char.IsOnDuty(),
        }
    end,

    ---@param src number
    ---@param jobName string
    ---@param grade string|number
    ---@return boolean
    Set = function(src, jobName, grade)
        local char = GetChar(src)
        if not char then return false end
        local gradeRank = tonumber(grade) or 0
        local gradeName = type(grade) == 'string' and grade or 'default'
        char.SetJob(jobName, jobName, gradeName, gradeName, gradeRank)
        return true
    end,

    ---@param src number
    ---@param status boolean
    ---@return boolean
    SetDuty = function(src, status)
        local char = GetChar(src)
        if not char then return false end
        char.SetOnDuty(status)
        return true
    end,

    ---@param src number
    ---@return boolean
    GetDuty = function(src)
        local char = GetChar(src)
        if not char then return false end
        return char.IsOnDuty()
    end,

    ---@param jobName string
    ---@return number[]
    GetPlayersWithJob = function(jobName)
        local result = {}
        local players = Oxide.Functions.GetPlayers()
        for _, player in pairs(players) do
            local char = player.GetCharacter()
            if char then
                local job = char.GetJob()
                if job and job.jobName == jobName then
                    result[#result + 1] = player.source
                end
            end
        end
        return result
    end,
})
