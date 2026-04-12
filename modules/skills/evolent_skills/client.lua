if GetResourceState('evolent_skills') == 'missing' then return end

olink._register('skills', {
    ---@return string
    GetResourceName = function()
        return 'evolent_skills'
    end,

    ---@param skillName string
    ---@return number
    GetSkillLevel = function(skillName)
        local skillData = exports.evolent_skills:getSkillLevel(skillName)
        return skillData or 0
    end,
})
