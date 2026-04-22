if not olink._guardImpl('Dispatch', 'redutzu-mdt', 'redutzu-mdt') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end

local function getStreetName(coords)
    if not coords then return 'Unknown' end
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    return GetStreetNameFromHashKey(streetHash) or 'Unknown'
end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'redutzu-mdt'
    end,

    ---@param data table
    SendAlert = function(data)
        local streetName = getStreetName(data.coords)
        TriggerServerEvent('o-link:dispatch:redutzu-mdt:sendAlert', {
            code = data.code or '10-80',
            message = data.message or 'Dispatch Alert',
            street = streetName,
            time = data.time or 10000,
            coords = data.coords,
        })
    end,
})
