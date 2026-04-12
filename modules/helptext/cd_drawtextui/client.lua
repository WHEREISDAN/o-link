if GetResourceState('cd_drawtextui') ~= 'started' then return end

olink._register('helptext', {
    ---@param message string
    ---@param position string|nil
    Show = function(message, position)
        TriggerEvent('cd_drawtextui:ShowUI', 'show', message)
    end,

    Hide = function()
        TriggerEvent('cd_drawtextui:HideUI')
    end,
})
