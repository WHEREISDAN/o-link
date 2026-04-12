if GetResourceState('evolent_skills') == 'missing' then return end

olink._register('skills', {
    ---@return string
    GetResourceName = function()
        return 'evolent_skills'
    end,

    ---@param src number
    ---@param skillName string
    ---@return number
    GetSkillLevel = function(src, skillName)
        local skillData = exports.evolent_skills:getSkillLevel(src, skillName)
        return skillData or 0
    end,

    ---@param src number
    ---@param skillName string
    ---@param amount number
    ---@return boolean
    AddXp = function(src, skillName, amount)
        local skillData = exports.evolent_skills:getSkillLevel(src, skillName)
        if not skillData then return false, print("Skill not found") end
        if not olink.skills.All[skillName] then
            olink.skills.All[skillName] = olink.skills.Create(skillName, 99, 50)
        end
        exports.evolent_skills:addXp(src, skillName, amount)
        return true
    end,

    ---@param src number
    ---@param skillName string
    ---@param amount number
    ---@return boolean
    RemoveXp = function(src, skillName, amount)
        local skillData = exports.evolent_skills:getSkillLevel(src, skillName)
        if not skillData then return false, print("Skill not found") end
        exports.evolent_skills:removeXp(src, skillName, amount)
        return true
    end,
})
