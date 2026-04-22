if not olink._guardImpl('Dispatch', 'cd_dispatch', 'cd_dispatch') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'cd_dispatch'
    end,

    ---@param data table
    SendAlert = function(data)
        local plyrData = exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = data.jobs,
            coords = data.coords,
            title = data.message,
            message = data.message,
            flash = 0,
            unique_id = plyrData.unique_id,
            sound = 1,
            blip = {
                sprite = data.blipData and data.blipData.sprite or 1,
                scale = data.blipData and data.blipData.scale or 1.0,
                colour = data.blipData and data.blipData.color or 1,
                flashes = false,
                text = data.message,
                time = data.time and (data.time / 1000) or 10,
                radius = 0,
            },
        })
    end,
})
