if GetResourceState('OT_skills') ~= 'started' then return end

olink._register('skills', {
    ---@return string
    GetResourceName = function()
        return 'OT_skills'
    end,

    ---@param src number
    ---@param skillName string
    ---@return number
    GetSkillLevel = function(src, skillName)
        local skillData = exports.OT_skills:getSkill(src, skillName)
        return skillData.level or 0
    end,

    ---@param src number
    ---@param skillName string
    ---@param amount number
    ---@return boolean
    AddXp = function(src, skillName, amount)
        local skillData = exports.OT_skills:getSkill(src, skillName)
        if not skillData then return false, print("Skill not found") end
        if not olink.skills.All[skillName] then
            olink.skills.All[skillName] = olink.skills.Create(skillName, 99, 50)
        end
        exports.OT_skills:addXP(src, skillName, amount)
        return true
    end,

    ---@param src number
    ---@param skillName string
    ---@param amount number
    ---@return boolean
    RemoveXp = function(src, skillName, amount)
        local skillData = exports.OT_skills:getSkill(src, skillName)
        if not skillData then return false, print("Skill not found") end
        exports.OT_skills:removeXP(src, skillName, amount)
        return true
    end,
})
