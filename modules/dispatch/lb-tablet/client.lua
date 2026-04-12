if GetResourceState('lb-tablet') ~= 'started' then return end

local function getPriorityLevel(priority)
    if priority == 1 then return 'low'
    elseif priority == 3 then return 'high'
    else return 'medium' end
end

local function getStreetName(coords)
    if not coords then return 'Unknown' end
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    return GetStreetNameFromHashKey(streetHash) or 'Unknown'
end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'lb-tablet'
    end,

    ---@param data table
    SendAlert = function(data)
        local streetName = getStreetName(data.coords)
        local priority = getPriorityLevel(data.priority)
        local job = type(data.jobs) == 'table' and data.jobs[1] or data.jobs
        local time = data.time
        if time and time > 1000 then
            time = math.floor((time / 1000) + 0.5)
        end
        local alertData = {
            priority = priority,
            code = data.code or '10-80',
            title = 'Dispatch Alert!',
            description = data.message,
            location = {
                label = streetName,
                coords = vec2(data.coords.x, data.coords.y),
            },
            time = time or 10000,
            job = job,
        }
        TriggerServerEvent('o-link:dispatch:lb-tablet:sendAlert', alertData)
    end,
})
