local RESOURCE='oxide-weather'
local function RegisterWeather()
    if not olink._guardImpl('Weather',RESOURCE,RESOURCE) then return end
    local function Call(method,...)
        if GetResourceState(RESOURCE)~='started' then return nil end
        local args=table.pack(...)
        local result=table.pack(pcall(function() return exports[RESOURCE][method](exports[RESOURCE],table.unpack(args,1,args.n)) end))
        if result[1] then return table.unpack(result,2,result.n) end
    end
    local api={ GetResourceName=function() return GetResourceState(RESOURCE)=='started' and RESOURCE or 'none' end,
        IsReady=function() return Call('IsReady')==true end,
        ToggleSync=function(enabled,owner)
            return Call('ToggleSync',enabled,GetInvokingResource() or owner or GetCurrentResourceName())==true
        end }
    for _,method in ipairs({'GetApiVersion', 'GetWeather', 'GetTime', 'IsBlackout', 'GetForecast', 'GetCurrentZone', 'GetWind', 'GetSeason', 'GetTemperature', 'GetTemperatureAt', 'GetSnowLevel', 'GetSnowLevelAt', 'GetFronts', 'GetCurrentFront', 'IsSyncEnabled', 'GetConditionsAt', 'GetWindAt', 'IsRainingAt', 'IsSnowOnGround', 'IsCovered', 'GetExposureAt', 'GetWeatherData', 'IsTimeFrozen', 'GetRoadConditionsAt'}) do api[method]=function(...) return Call(method,...) end end
    for _,method in ipairs({'RegisterExposureEntity','UnregisterExposureEntity'}) do
        api[method]=function(entity) return Call(method,entity,GetInvokingResource() or GetCurrentResourceName())==true end
    end
    olink._register('weather',api,RESOURCE)
end
RegisterWeather()
AddEventHandler('onClientResourceStart',function(name) if name==RESOURCE then RegisterWeather() TriggerEvent('olink:client:weather:ready') end end)
AddEventHandler('onClientResourceStop',function(name) if name==RESOURCE then TriggerEvent('olink:client:weather:stopped') end end)
