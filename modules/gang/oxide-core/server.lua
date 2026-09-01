if not olink._guardImpl('Gang', 'oxide-core', 'oxide-core') then return end

-- Organization-slot mirror. When oxide-gangs is installed it owns the gang
-- registry and the adapter below yields the namespace to it, but the core's
-- per-character organization slot still has to be filled: core-native reads
-- (Session.GetOrganization) resolve against it. The push lives here, in the
-- bridge, so oxide-gangs itself carries no oxide-core code. Push-only; never
-- read back. The job slot is untouched, so gang + job coexist.
AddEventHandler('oxide:gangs:server:syncPlayer', function(src, gang, member, grade)
    if GetResourceState('oxide-core') ~= 'started' then return end
    local ok, err = pcall(function()
        local player = exports['oxide-core']:Core().Functions.GetPlayer(src)
        if not player then return end
        local char = player.GetCharacter()
        if not char then return end
        if gang then
            char.SetOrganization(gang.name, gang.label,
                grade and grade.grade_name or 'member',
                grade and grade.grade_label or 'Member',
                member and member.grade_rank or 0)
        else
            char.SetOrganization(nil)
        end
    end)
    if not ok then
        olink.logger.Warn('o-link', 'gang', 'oxide-core organization mirror failed', { error = tostring(err) })
    end
end)

if not olink._hasOverride('Gang') and GetResourceState('oxide-gangs') ~= 'missing' then return end

local Oxide = exports['oxide-core']:Core()

local function GetChar(src)
    local player = Oxide.Functions.GetPlayer(src)
    if not player then return nil end
    return player.GetCharacter()
end

olink._register('gang', {
    ---@param src number
    ---@return table|nil { name, label, grade, gradeLabel, rank }
    Get = function(src)
        local char = GetChar(src)
        if not char then return nil end
        local org = char.GetOrganization()
        if not org or not org.orgName then return nil end
        return {
            name       = org.orgName,
            label      = org.orgLabel or org.orgName,
            grade      = org.gradeName or 'default',
            gradeLabel = org.gradeLabel or 'Default',
            rank       = org.gradeRank or 0,
        }
    end,

    ---@param src number
    ---@param orgName string|nil pass nil to clear
    ---@param orgLabel string|nil
    ---@param gradeName string|nil
    ---@param gradeLabel string|nil
    ---@param gradeRank number|nil
    ---@return boolean
    Set = function(src, orgName, orgLabel, gradeName, gradeLabel, gradeRank)
        local char = GetChar(src)
        if not char then return false end
        char.SetOrganization(orgName, orgLabel, gradeName, gradeLabel, gradeRank)
        return true
    end,
})
