if not olink._guardImpl('Dispatch', 'origen_police', 'origen_police') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'origen_police'
    end,

    ---@param data table
    SendAlert = function(data)
        local color = nil
        if data.vehicle then
            local r, g, b = GetVehicleColor(data.vehicle)
            color = { r, g, b }
        end
        TriggerServerEvent('SendAlert:police', {
            coords = data.coords or vector3(0.0, 0.0, 0.0),
            title = 'Alert ' .. (data.code or '10-80'),
            message = data.message,
            job = data.jobs or 'police',
            metadata = {
                model = data.vehicle and GetDisplayNameFromVehicleModel(GetEntityModel(data.vehicle)) or nil,
                color = color,
                plate = data.vehicle and GetVehicleNumberPlateText(data.vehicle) or nil,
                speed = data.vehicle and (GetEntitySpeed(data.vehicle) * 3.6) .. ' kmh' or nil,
            },
        })
    end,
})
