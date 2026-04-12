if GetResourceState('ox_fuel') == 'missing' then return end
if GetResourceState('oxide-vehicles') == 'started' then return end

olink._register('fuel', {
    ---@return string
    GetResourceName = function()
        return 'ox_fuel'
    end,

    ---@param vehicle number
    ---@return number
    GetFuel = function(vehicle)
        if not DoesEntityExist(vehicle) then return 0.0 end
        return Entity(vehicle).state.fuel
    end,

    ---@param vehicle number
    ---@param fuel number
    ---@param type? string
    SetFuel = function(vehicle, fuel, type)
        if not DoesEntityExist(vehicle) then return end
        local state = Entity(vehicle).state
        state.fuel = (state.fuel or 0) + fuel
    end,
})
