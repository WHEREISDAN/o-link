if GetResourceState('oxide-progressbar') == 'started' then return end
if GetResourceState('progressbar') == 'started' then return end
if GetResourceState('keep-progressbar') == 'started' then return end
if GetResourceState('lation_ui') == 'started' then return end
if GetResourceState('wasabi_uikit') == 'started' then return end
if GetResourceState('ZSX_UIV2') == 'missing' then return end

olink._register('progressbar', {
    ---@param options table { duration, label, canCancel?, disable?: { move, car, combat, mouse }, anim?: { dict, clip, flag } }
    ---@param callback function|nil
    ---@return boolean
    Open = function(options, callback)
        local disable = options.disable
        local disableControls = disable and {
            disable_mouse   = disable.mouse,
            disable_walk    = disable.move,
            disable_driving = disable.car,
            disable_combat  = disable.combat,
        } or nil

        local prop1 = options.prop and (options.prop[1] or options.prop) or nil
        local prop2 = options.prop and options.prop[2] or nil

        local prom = promise.new()
        exports['ZSX_UIV2']:ProgressBar(
            'fas fa-circle-notch',
            options.label,
            options.duration or 5000,
            function()
                if callback then callback(true) end
                prom:resolve(true)
            end,
            function()
                if callback then callback(false) end
                prom:resolve(false)
            end,
            options.canCancel,
            disableControls,
            options.anim and {
                dict  = options.anim.dict,
                clip  = options.anim.clip,
                flag  = options.anim.flag or 49,
            } or nil,
            prop1 and prop1.model and {
                model = prop1.model,
                bone  = prop1.bone,
                pos   = prop1.pos,
                rot   = prop1.rot,
            } or nil,
            prop2 and prop2.model and {
                model = prop2.model,
                bone  = prop2.bone,
                pos   = prop2.pos,
                rot   = prop2.rot,
            } or nil
        )
        return Citizen.Await(prom)
    end,
})
