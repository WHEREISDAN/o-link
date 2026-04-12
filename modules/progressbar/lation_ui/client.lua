if GetResourceState('oxide-progressbar') == 'started' then return end
if GetResourceState('progressbar') == 'started' then return end
if GetResourceState('keep-progressbar') == 'started' then return end
if GetResourceState('lation_ui') ~= 'started' then return end

olink._register('progressbar', {
    ---@param options table { duration, label, canCancel?, disable?: { move, car, combat, mouse }, anim?: { dict, clip, flag } }
    ---@param callback function|nil
    ---@return boolean
    Open = function(options, callback)
        local lationOptions = {
            duration  = options.duration,
            label     = options.label,
            canCancel = options.canCancel,
            useWhileDead = options.useWhileDead,
            disable   = options.disable,
            anim      = options.anim,
        }

        local success = exports.lation_ui:progressBar(lationOptions)
        if callback then callback(success) end
        return success
    end,
})
