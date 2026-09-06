local function RegisterWeather()
    if not olink._guardImpl('Weather', 'oxide-weather', 'oxide-weather') then return end
    olink._register('weather', {
        ---@return string
        GetResourceName = function()
            return 'oxide-weather'
        end,

        ---@param toggle boolean
        ToggleSync = function(toggle, owner)
            owner = owner or GetInvokingResource() or GetCurrentResourceName()
            local ok, result = pcall(function() return exports['oxide-weather']:ToggleSync(toggle, owner) end)
            return ok and result or false
        end,

        ---@return string
        GetWeather = function()
            local ok, weather = pcall(function() return exports['oxide-weather']:GetWeather() end)
            return ok and weather or GlobalState['oxide:weather'] or 'CLEAR'
        end,

        ---@return table { hour: number, minute: number }
        GetTime = function()
            local ok, time = pcall(function() return exports['oxide-weather']:GetTime() end)
            return ok and time or GlobalState['oxide:time'] or { hour = 12, minute = 0 }
        end,
    }, 'oxide-weather')
end

RegisterWeather()

-- oxide-weather now depends on o-link, so it can start after adapter discovery.
-- Merge into the existing namespace to update references already held by callers.
AddEventHandler('onClientResourceStart', function(resource)
    if resource == 'oxide-weather' then RegisterWeather() end
end)
