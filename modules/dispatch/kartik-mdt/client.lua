if not olink._guardImpl('Dispatch', 'kartik-mdt', 'kartik-mdt') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'kartik-mdt'
    end,

    ---@param data table
    SendAlert = function(data)
        local repackJobsBools = {}
        for k, v in pairs(data.jobs or {}) do
            if v then repackJobsBools[k] = true end
        end
        exports['kartik-mdt']:CustomAlert({
            title = data.message or 'Alert',
            code = data.code or '10-80',
            description = data.message,
            type = 'Alert',
            coords = data.coords,
            blip = {
                radius = 100.0,
                sprite = data.blipData and data.blipData.sprite or 161,
                color = data.blipData and data.blipData.color or 1,
                scale = data.blipData and data.blipData.scale or 0.8,
                length = 2,
            },
            jobs = repackJobsBools,
        })
    end,
})
