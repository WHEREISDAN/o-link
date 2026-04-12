if GetResourceState('qs-fuelstations') == 'missing' then return end
if GetResourceState('oxide-vehicles') == 'started' then return end

olink._register('fuel', {
    ---@return string
    GetResourceName = function()
        return 'qs-fuelstations'
    end,

    ---@param vehicle number
    ---@return number
    GetFuel = function(vehicle)
        if not DoesEntityExist(vehicle) then return 0.0 end
        return exports['qs-fuelstations']:GetFuel(vehicle)
    end,

    ---@param vehicle number
    ---@param fuel number
    ---@param type? string
    SetFuel = function(vehicle, fuel, type)
        if not DoesEntityExist(vehicle) then return end
        exports['qs-fuelstations']:SetFuel(vehicle, fuel)
    end,
})
