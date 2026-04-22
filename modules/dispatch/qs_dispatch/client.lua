if not olink._guardImpl('Dispatch', 'qs_dispatch', 'qs-dispatch') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'qs-dispatch'
    end,

    ---@param data table
    SendAlert = function(data)
        local playerData = exports['qs-dispatch']:GetPlayerInfo()
        if not playerData then return end

        exports['qs-dispatch']:getSSURL(function(image)
            TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', {
                job = data.jobs or { 'police' },
                callLocation = data.coords or vec3(0.0, 0.0, 0.0),
                callCode = {
                    code = data.code or '10-80',
                    snippet = data.snippet or 'General Alert',
                },
                message = data.message,
                flashes = false,
                image = image or nil,
                blip = {
                    sprite = data.blipData and data.blipData.sprite or 1,
                    scale = data.blipData and data.blipData.scale or 1.0,
                    colour = data.blipData and data.blipData.color or 1,
                    flashes = false,
                    text = data.message or 'Alert',
                    time = data.time or 20000,
                },
                otherData = {
                    {
                        text = data.name or 'N/A',
                        icon = data.icon or 'fas fa-question',
                    },
                },
            })
        end)
    end,
})
