if GetResourceState('pickle_xp') == 'missing' then return end

olink._register('skills', {
    ---@return string
    GetResourceName = function()
        return 'pickle_xp'
    end,

    ---@param src number
    ---@param skillName string
    ---@return number
    GetSkillLevel = function(src, skillName)
        local skillData = exports.pickle_xp:GetPlayerLevel(src, skillName)
        return skillData or 0
    end,

    ---@param src number
    ---@param skillName string
    ---@param amount number
    ---@return boolean
    AddXp = function(src, skillName, amount)
        local skillData = exports.pickle_xp:GetPlayerLevel(src, skillName)
        if not skillData then return false, print("^6 Skill " .. skillName .. " not found ^0 ") end
        if not olink.skills.All[skillName] then olink.skills.All[skillName] = olink.skills.Create(skillName, 99, 50) end
        exports.pickle_xp:AddPlayerXP(src, skillName, amount)
        return true
    end,

    ---@param src number
    ---@param skillName string
    ---@param amount number
    ---@return boolean
    RemoveXp = function(src, skillName, amount)
        local skillData = exports.pickle_xp:GetPlayerLevel(src, skillName)
        if not skillData then return false, print("Skill not found") end
        exports.pickle_xp:RemovePlayerXP(src, skillName, amount)
        return true
    end,
})
