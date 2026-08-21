if not olink._guardImpl('Gang', 'oxide-core', 'oxide-core') then return end
if not olink._hasOverride('Gang') and GetResourceState('oxide-gangs') ~= 'missing' then return end

olink._register('gang', {
    ---@return table|nil { name, label, grade, gradeLabel, rank }
    Get = function()
        local org = LocalPlayer.state['oxide:organization']
        if not org or not org.orgName then return nil end
        return {
            name       = org.orgName,
            label      = org.orgLabel or org.orgName,
            grade      = org.gradeName or 'default',
            gradeLabel = org.gradeLabel or 'Default',
            rank       = org.gradeRank or 0,
        }
    end,
})
