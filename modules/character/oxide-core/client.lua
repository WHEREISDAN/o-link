if GetResourceState('oxide-core') == 'missing' then return end

olink._register('character', {
    ---@return string|nil
    GetIdentifier = function()
        local char = LocalPlayer.state['oxide:character']
        if not char then return nil end
        return tostring(char.stateId)
    end,

    ---@return string|nil firstName, string|nil lastName
    GetName = function()
        local char = LocalPlayer.state['oxide:character']
        if not char then return nil, nil end
        return char.firstName, char.lastName
    end,

    ---@param key string
    ---@return any|nil
    GetMetadata = function(key)
        local char = LocalPlayer.state['oxide:character']
        if not char then return nil end
        if char.metadata then return char.metadata[key] end
        return nil
    end,
})
