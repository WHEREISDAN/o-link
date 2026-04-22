if not olink._guardImpl('ProgressBar', 'ox_lib', 'ox_lib') then return end
if not olink._hasOverride('ProgressBar') and GetResourceState('oxide-progressbar') == 'started' then return end
if not olink._hasOverride('ProgressBar') and GetResourceState('progressbar') == 'started' then return end
if not olink._hasOverride('ProgressBar') and GetResourceState('esx_progressbar') == 'started' then return end
if not olink._hasOverride('ProgressBar') and GetResourceState('keep-progressbar') == 'started' then return end
if not olink._hasOverride('ProgressBar') and GetResourceState('lation_ui') == 'started' then return end
if not olink._hasOverride('ProgressBar') and GetResourceState('wasabi_uikit') == 'started' then return end
if not olink._hasOverride('ProgressBar') and GetResourceState('ZSX_UIV2') == 'started' then return end

---Converts a QB-style progress options table into the Ox format lib.progressBar expects.
---@param options table
---@return table
local function convertFromQB(options)
    if not options then return options end
    local prop1 = options.prop or {}
    local prop2 = options.propTwo or {}
    local props = {
        { model = prop1.model, bone = prop1.bone, pos = prop1.coords, rot = prop1.rotation },
        { model = prop2.model, bone = prop2.bone, pos = prop2.coords, rot = prop2.rotation },
    }
    return {
        duration = options.duration,
        label = options.label,
        position = 'bottom',
        useWhileDead = options.useWhileDead,
        canCancel = options.canCancel,
        disable = options.controlDisables and {
            move   = options.controlDisables.disableMovement,
            car    = options.controlDisables.disableCarMovement,
            combat = options.controlDisables.disableCombat,
            mouse  = options.controlDisables.disableMouse,
        } or nil,
        anim = options.animation and {
            dict = options.animation.animDict,
            clip = options.animation.anim,
            flag = options.animation.flags or 49,
        } or nil,
        prop = props,
    }
end

olink._register('progressbar', {
    ---@param options table Ox- or QB-format progress bar options
    ---@param callback function|nil
    ---@param isQBInput boolean|nil when true, options is treated as QB-format and converted
    ---@return boolean
    Open = function(options, callback, isQBInput)
        if isQBInput then
            options = convertFromQB(options)
        end

        local style = options.style or 'bar'
        local disable = options.disable or {}
        local anim = options.anim

        local payload = {
            duration     = options.duration,
            label        = options.label,
            position     = options.position,
            canCancel    = options.canCancel or false,
            useWhileDead = options.useWhileDead or false,
            disable = {
                move   = disable.move,
                car    = disable.car,
                combat = disable.combat,
                mouse  = disable.mouse,
            },
            anim = anim and {
                dict = anim.dict,
                clip = anim.clip,
                flag = anim.flag,
            } or nil,
            prop = options.prop,
        }

        local result = style == 'circle' and lib.progressCircle(payload) or lib.progressBar(payload)

        if callback then
            callback(result)
        end

        return result
    end,
})
