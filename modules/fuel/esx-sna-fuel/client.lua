if GetResourceState('esx-sna-fuel') == 'missing' then return end
if GetResourceState('oxide-vehicles') == 'started' then return end

olink._register('fuel', {
    ---@return string
    GetResourceName = function()
        return 'esx-sna-fuel'
    end,

    ---@param vehicle number
    ---@return number
    GetFuel = function(vehicle)
        if not DoesEntityExist(vehicle) then return 0.0 end
        return exports['esx-sna-fuel']:GetFuel(vehicle)
    end,

    ---@param vehicle number
    ---@param fuel number
    ---@param type? string
    SetFuel = function(vehicle, fuel, type)
        if not DoesEntityExist(vehicle) then return end
        exports['esx-sna-fuel']:SetFuel(vehicle, fuel)
    end,
})
