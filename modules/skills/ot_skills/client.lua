if GetResourceState('OT_skills') ~= 'started' then return end

olink._register('skills', {
    ---@return string
    GetResourceName = function()
        return 'OT_skills'
    end,

    ---@param skillName string
    ---@return number
    GetSkillLevel = function(skillName)
        local skillData = exports.OT_skills:getSkill(skillName)
        return skillData.level or 0
    end,
})
