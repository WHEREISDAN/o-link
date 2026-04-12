if GetResourceState('tk_dispatch') ~= 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'tk_dispatch'
    end,

    ---@param data table
    SendAlert = function(data)
        exports.tk_dispatch:addCall({
            title = data.message,
            code = data.code or '10-80',
            priority = 'Priority 3',
            coords = data.coords or GetEntityCoords(PlayerPedId()),
            showLocation = true,
            showGender = false,
            playSound = true,
            blip = {
                color = data.blipData and data.blipData.color or 3,
                sprite = data.blipData and data.blipData.sprite or 1,
                scale = data.blipData and data.blipData.scale or 0.8,
            },
            jobs = data.jobs or { 'police' },
        })
    end,
})
