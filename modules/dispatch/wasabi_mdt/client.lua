if not olink._guardImpl('Dispatch', 'wasabi_mdt', 'wasabi_mdt') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'wasabi_mdt'
    end,

    ---@param data table
    SendAlert = function(data)
        local fallbackCoords = GetEntityCoords(PlayerPedId())
        local coords = data.coords or fallbackCoords
        -- Match community_bridge shape exactly: wasabi_mdt expects coord arrays
        -- ({x, y, z}) for both `location` and `coords`, not tables keyed by axis.
        local coordArray = { coords.x, coords.y, coords.z }
        exports.wasabi_mdt:CreateDispatch({
            type = data.code or '10-80',
            title = data.code or '10-80',
            description = data.message or 'No message provided',
            location = coordArray,
            coords = coordArray,
        })
    end,
})
