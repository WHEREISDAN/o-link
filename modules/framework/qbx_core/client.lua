if GetResourceState('qbx_core') ~= 'started' then return end

local QBox = exports.qbx_core

olink._register('framework', {
    ---@return string
    GetName = function()
        return 'qbx_core'
    end,

    ---@return boolean
    GetIsPlayerLoaded = function()
        return LocalPlayer.state.isLoggedIn or false
    end,
})
