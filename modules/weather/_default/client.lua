-- Default weather fallback.
-- Uses GTA native clock/weather readers when no dedicated sync resource is running.

if not olink._guardImpl('Weather', '_default', false) then return end
if not olink._hasOverride('Weather') and GetResourceState('cd_easytime') == 'started' then return end
if not olink._hasOverride('Weather') and GetResourceState('night_natural_disasters') == 'started' then return end
if not olink._hasOverride('Weather') and GetResourceState('oxide-weather') == 'started' then return end
if not olink._hasOverride('Weather') and GetResourceState('qb-weathersync') == 'started' then return end
if not olink._hasOverride('Weather') and GetResourceState('Renewed-Weathersync') == 'started' then return end
if not olink._hasOverride('Weather') and GetResourceState('renewed-weathersync') == 'started' then return end

local weatherNames = {
    [`EXTRASUNNY`] = 'EXTRASUNNY',
    [`CLEAR`] = 'CLEAR',
    [`NEUTRAL`] = 'NEUTRAL',
    [`SMOG`] = 'SMOG',
    [`FOGGY`] = 'FOGGY',
    [`OVERCAST`] = 'OVERCAST',
    [`CLOUDS`] = 'CLOUDS',
    [`CLEARING`] = 'CLEARING',
    [`RAIN`] = 'RAIN',
    [`THUNDER`] = 'THUNDER',
    [`SNOW`] = 'SNOW',
    [`BLIZZARD`] = 'BLIZZARD',
    [`SNOWLIGHT`] = 'SNOWLIGHT',
    [`XMAS`] = 'XMAS',
    [`HALLOWEEN`] = 'HALLOWEEN',
}

olink._registerDefault('weather', {
    GetResourceName = function() return '_default' end,

    ToggleSync = function() end,

    GetWeather = function()
        return weatherNames[GetPrevWeatherType()] or 'CLEAR'
    end,

    GetTime = function()
        return { hour = GetClockHours(), minute = GetClockMinutes() }
    end,
})
