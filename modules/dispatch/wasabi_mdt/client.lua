if GetResourceState('wasabi_mdt') == 'missing' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'wasabi_mdt'
    end,

    ---@param data table
    SendAlert = function(data)
        local fallbackCoords = GetEntityCoords(PlayerPedId())
        local coords = data.coords or fallbackCoords
        exports.wasabi_mdt:CreateDispatch({
            type = data.code or '10-80',
            title = data.code or '10-80',
            description = data.message or 'No message provided',
            location = { coords.x, coords.y, coords.z },
            coords = { coords.x, coords.y, coords.z },
        })
    end,
})
