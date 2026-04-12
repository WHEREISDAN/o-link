if GetResourceState('oxide-vehicles') ~= 'started' then return end

olink._register('fuel', {
    ---@return string
    GetResourceName = function()
        return 'oxide-vehicles'
    end,

    ---@param vehicle number
    ---@return number
    GetFuel = function(vehicle)
        if not DoesEntityExist(vehicle) then return 0.0 end
        return exports['oxide-vehicles']:GetFuel(vehicle)
    end,

    ---@param vehicle number
    ---@param fuel number
    ---@param type? string
    SetFuel = function(vehicle, fuel, type)
        if not DoesEntityExist(vehicle) then return end
        exports['oxide-vehicles']:SetFuel(vehicle, fuel)
    end,
})
