if GetResourceState('oxide-progressbar') == 'started' then return end
if GetResourceState('progressbar') == 'started' then return end
if GetResourceState('keep-progressbar') == 'started' then return end
if GetResourceState('lation_ui') == 'started' then return end
if GetResourceState('wasabi_uikit') ~= 'started' then return end

olink._register('progressbar', {
    ---@param options table { duration, label, canCancel?, style?: string, disable?: { move, car, combat, mouse }, anim?: { dict, clip, flag } }
    ---@param callback function|nil
    ---@return boolean
    Open = function(options, callback)
        local style = options.style or 'bar'
        local success = exports.wasabi_uikit:ProgressBar(options, style)
        if callback then callback(success) end
        return success
    end,
})
