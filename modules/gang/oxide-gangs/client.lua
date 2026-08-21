local RESOURCE = 'oxide-gangs'

if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Gang', RESOURCE, false) then return end

local function isStarted()
    return GetResourceState(RESOURCE) == 'started'
end

olink._register('gang', {
    ---@return string
    GetResourceName = function() return RESOURCE end,

    ---Reads the server-written oxide:gang statebag — no round-trip.
    ---@return table|nil { name, label, grade, gradeLabel, rank }
    Get = function()
        if not isStarted() then return nil end
        local g = LocalPlayer.state['oxide:gang']
        if not g or not g.name then return nil end
        return {
            name       = g.name,
            label      = g.label or g.name,
            grade      = g.grade or 'default',
            gradeLabel = g.gradeLabel or 'Default',
            rank       = g.rank or 0,
        }
    end,

    ---@return table[] { id, name, label, color, motto, memberCount }
    GetAll = function()
        if not isStarted() then return {} end
        return olink.callback.Trigger('oxide-gangs:server:gang:getAll') or {}
    end,

    ---@param gangName string
    ---@return table[] { rank, name, label, isBoss, permissions }
    GetGrades = function(gangName)
        if not isStarted() then return {} end
        return olink.callback.Trigger('oxide-gangs:server:gang:getGrades', gangName) or {}
    end,

    ---@param perm string
    ---@return boolean
    HasPermission = function(perm)
        if not isStarted() then return false end
        return olink.callback.Trigger('oxide-gangs:server:gang:hasPermission', perm) == true
    end,
}, RESOURCE)
