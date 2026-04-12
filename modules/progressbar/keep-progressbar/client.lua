if GetResourceState('oxide-progressbar') == 'started' then return end
if GetResourceState('progressbar') == 'started' then return end
if GetResourceState('keep-progressbar') ~= 'started' then return end

olink._register('progressbar', {
    ---@param options table { duration, label, canCancel?, disable?: { move, car, combat, mouse }, anim?: { dict, clip, flag } }
    ---@param callback function|nil
    ---@return boolean
    Open = function(options, callback)
        local success = exports['keep-progressbar']:ox_lib_progressBar(options)
        if callback then callback(success) end
        return success
    end,
})
