if GetResourceState('pickle_xp') ~= 'started' then return end

olink._register('skills', {
    ---@return string
    GetResourceName = function()
        return 'pickle_xp'
    end,

    ---@param skillName string
    ---@return number
    GetSkillLevel = function(skillName)
        local skillData = exports.pickle_xp:GetLevel(skillName)
        return skillData or 0
    end,
})
