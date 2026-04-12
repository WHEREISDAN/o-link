if GetResourceState('ZSX_UIV2') ~= 'started' then return end

olink._register('helptext', {
    ---@param message string
    ---@param position string|nil
    Show = function(message, position)
        exports['ZSX_UIV2']:TextUI_Persistent(nil, message, nil, nil, nil)
    end,

    Hide = function()
        exports['ZSX_UIV2']:TextUI_RemovePersistent(false)
    end,
})
