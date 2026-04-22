if not olink._guardImpl('ProgressBar', 'qb-progressbar', 'progressbar') then return end
if not olink._hasOverride('ProgressBar') and GetResourceState('oxide-progressbar') == 'started' then return end

---Converts an Ox-style progress options table into the QB format exports.progressbar:Progress expects.
---@param options table
---@return table
local function convertFromOx(options)
    if not options then return options end
    local prop1 = (options.prop and options.prop[1]) or options.prop or {}
    local prop2 = (options.prop and options.prop[2]) or {}
    return {
        name     = options.label,
        duration = options.duration,
        label    = options.label,
        useWhileDead = options.useWhileDead,
        canCancel    = options.canCancel,
        controlDisables = options.disable and {
            disableMovement    = options.disable.move,
            disableCarMovement = options.disable.car,
            disableMouse       = options.disable.mouse,
            disableCombat      = options.disable.combat,
        } or nil,
        animation = options.anim and {
            animDict = options.anim.dict,
            anim     = options.anim.clip,
            flags    = options.anim.flag or 49,
        } or nil,
        prop = prop1.model and {
            model    = prop1.model,
            bone     = prop1.bone,
            coords   = prop1.pos,
            rotation = prop1.rot,
        } or nil,
        propTwo = prop2.model and {
            model    = prop2.model,
            bone     = prop2.bone,
            coords   = prop2.pos,
            rotation = prop2.rot,
        } or nil,
    }
end

olink._register('progressbar', {
    ---@param options table Ox- or QB-format progress bar options
    ---@param callback function|nil
    ---@param qbFormat boolean|nil when true, options is already in QB format — skip conversion
    ---@return boolean
    Open = function(options, callback, qbFormat)
        local qbOptions = qbFormat and options or convertFromOx(options)

        local prom = promise.new()
        exports['progressbar']:Progress(qbOptions, function(cancelled)
            local result = not cancelled
            if callback then callback(result) end
            prom:resolve(result)
        end)
        return Citizen.Await(prom)
    end,
})
