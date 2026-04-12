if GetResourceState('qb-weathersync') ~= 'started' then return end
if GetResourceState('oxide-weather') == 'started' then return end

local trackedWeather = 'EXTRASUNNY'

RegisterNetEvent('qb-weathersync:client:SyncWeather', function(newWeather)
    trackedWeather = newWeather
end)

TriggerServerEvent('qb-weathersync:server:RequestStateSync')

olink._register('weather', {
    ---@return string
    GetResourceName = function()
        return 'qb-weathersync'
    end,

    ---@param toggle boolean
    ToggleSync = function(toggle)
        if toggle then
            TriggerEvent('qb-weathersync:client:EnableSync')
        else
            TriggerEvent('qb-weathersync:client:DisableSync')
        end
    end,

    ---@return string
    GetWeather = function()
        return trackedWeather
    end,

    ---@return table { hour: number, minute: number }
    GetTime = function()
        return { hour = GetClockHours(), minute = GetClockMinutes() }
    end,
})
