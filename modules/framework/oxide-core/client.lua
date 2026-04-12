if GetResourceState('oxide-core') ~= 'started' then return end

olink._register('framework', {
    ---@return string
    GetName = function()
        return 'oxide-core'
    end,

    ---@return boolean
    GetIsPlayerLoaded = function()
        return LocalPlayer.state['oxide:character'] ~= nil
    end,
})
