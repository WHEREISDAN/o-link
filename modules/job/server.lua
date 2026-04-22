-- Framework-agnostic job helpers built on top of olink.job.Get.
-- Loads after adapters due to alphabetical glob ordering.

olink._register('job', {
    ---Check whether a player currently holds the given job (optionally at a minimum grade).
    ---@param src number
    ---@param jobName string
    ---@param minGrade number|nil
    ---@return boolean
    DoesPlayerHaveJob = function(src, jobName, minGrade)
        if not olink.job or not olink.job.Get then return false end
        local data = olink.job.Get(src)
        if not data or data.name ~= jobName then return false end
        if minGrade and (data.rank or 0) < minGrade then return false end
        return true
    end,
})
