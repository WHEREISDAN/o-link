if not olink._guardImpl('Framework', 'qbx_core', 'qbx_core') then return end

local QBox = exports.qbx_core

olink._register('framework', {
    GetResourceName = function()
        return 'qbx_core'
    end,

    ---@return string
    GetName = function()
        return 'qbx_core'
    end,

    ---@return boolean
    GetIsPlayerLoaded = function()
        return LocalPlayer.state.isLoggedIn or false
    end,

    ShowHelpText = function(message, position)
        return lib.showTextUI(message, { position = position or 'top-center' })
    end,

    HideHelpText = function()
        return lib.hideTextUI()
    end,
})
