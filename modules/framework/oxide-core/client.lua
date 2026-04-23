if not olink._guardImpl('Framework', 'oxide-core', 'oxide-core') then return end

olink._register('framework', {
    GetResourceName = function()
        return 'oxide-core'
    end,

    ---@return string
    GetName = function()
        return 'oxide-core'
    end,

    ---@return boolean
    GetIsPlayerLoaded = function()
        return LocalPlayer.state['oxide:character'] ~= nil
    end,

    ShowHelpText = function(message, position)
        lib.showTextUI(message, { position = position })
    end,

    HideHelpText = function()
        lib.hideTextUI()
    end,
})
