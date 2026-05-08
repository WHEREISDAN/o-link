local RESOURCE = 'oxide-vehicles'

if GetResourceState(RESOURCE) == 'missing' then return end
if not olink._guardImpl('Fuel', RESOURCE, false) then return end

local res = exports[RESOURCE]

local function isStarted()
    return GetResourceState(RESOURCE) == 'started'
end

olink._register('fuel', {
    ---@return string
    GetResourceName = function() return RESOURCE end,

    ---@param vehicle number
    ---@return number
    GetFuel = function(vehicle)
        if not DoesEntityExist(vehicle) then return 0.0 end
        if not isStarted() then return 0.0 end
        local ok, result = pcall(function() return res:GetFuel(vehicle) end)
        return ok and tonumber(result) or 0.0
    end,

    ---@param vehicle number
    ---@param fuel number
    ---@param type? string
    SetFuel = function(vehicle, fuel, type)
        if not DoesEntityExist(vehicle) then return end
        if not isStarted() then return end
        pcall(function() res:SetFuel(vehicle, fuel) end)
    end,
}, RESOURCE)
