if GetResourceState('oxide-weather') ~= 'started' then return end

olink._register('weather', {
    ---@return string
    GetResourceName = function()
        return 'oxide-weather'
    end,

    ---@param toggle boolean
    ToggleSync = function(toggle)
        -- oxide-weather sync is server-authoritative; no client toggle needed
    end,

    ---@return string
    GetWeather = function()
        return GlobalState['oxide:weather'] or 'CLEAR'
    end,

    ---@return table { hour: number, minute: number }
    GetTime = function()
        return GlobalState['oxide:time'] or { hour = 12, minute = 0 }
    end,
})
