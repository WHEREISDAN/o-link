if not olink._guardImpl('Dispatch', 'redutzu-mdt', 'redutzu-mdt') then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end

olink._register('dispatch', {
    ---@return string
    GetResourceName = function()
        return 'redutzu-mdt'
    end,
})

RegisterNetEvent('o-link:dispatch:redutzu-mdt:sendAlert', function(data)
    TriggerEvent('redutzu-mdt:server:addDispatchToMDT', {
        code = data.code,
        title = data.message,
        street = data.street,
        duration = data.time,
        coords = data.coords,
    })
end)
