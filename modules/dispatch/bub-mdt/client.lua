if GetResourceState('bub-mdt') == 'missing' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'bub-mdt'
    end,

    ---@param data table
    SendAlert = function(data)
        local ped = PlayerPedId()
        local alertData = {
            code = data.code or '10-80',
            offense = data.message,
            coords = data.coords or GetEntityCoords(ped),
            info = { label = data.code or '10-80', icon = data.icon or 'fas fa-question' },
            blip = data.blipData and data.blipData.sprite or 1,
            isEmergency = data.priority == 1 and true or false,
            blipCoords = data.coords or GetEntityCoords(ped),
        }
        exports['bub-mdt']:CustomAlert(alertData)
    end,
})
