-- Framework-agnostic gang helpers built on top of olink.gang.Get.

olink._register('gang', {
    ---Check whether a player currently belongs to the given gang (optionally at a minimum grade).
    ---@param src number
    ---@param gangName string
    ---@param minGrade number|nil
    ---@return boolean
    DoesPlayerHaveGang = function(src, gangName, minGrade)
        if not olink.gang or not olink.gang.Get then return false end
        local data = olink.gang.Get(src)
        if not data or data.name ~= gangName then return false end
        if minGrade and (data.rank or 0) < minGrade then return false end
        return true
    end,
})
