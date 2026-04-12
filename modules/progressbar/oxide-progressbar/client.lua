if GetResourceState('oxide-progressbar') ~= 'started' then return end

olink._register('progressbar', {
    ---@param options table { duration, label, canCancel?, disable?: { move, car, combat, mouse }, anim?: { dict, clip, flag } }
    ---@param callback function|nil
    ---@return boolean
    Open = function(options, callback)
        if not options then return false end

        local progressOptions = {
            duration  = options.duration,
            label     = options.label,
            canCancel = options.canCancel,
        }

        if options.anim then
            progressOptions.animation = {
                dict  = options.anim.dict,
                clip  = options.anim.clip,
                flags = options.anim.flag or options.anim.flags or 49,
            }
        end

        if options.prop then
            progressOptions.prop = {
                model    = options.prop.model,
                bone     = options.prop.bone,
                offset   = options.prop.offset or options.prop.pos,
                rotation = options.prop.rotation or options.prop.rot,
            }
        end

        if options.disable then
            progressOptions.disableControls = {
                disableMovement    = options.disable.move,
                disableCombat      = options.disable.combat,
                disableCarMovement = options.disable.car,
                disableMouse       = options.disable.mouse,
            }
        end

        local success = exports['oxide-progressbar']:Progress(progressOptions)

        if callback then callback(success) end
        return success
    end,
})
