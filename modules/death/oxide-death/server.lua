if not olink._guardImpl('Death', 'oxide-death', 'oxide-death') then return end

olink._register('death', {
    ---@param src number
    ---@return boolean
    IsPlayerDowned = function(src)
        return exports['oxide-death']:IsPlayerDowned(src) == true
    end,

    ---@param src number
    ---@return boolean
    IsPlayerDead = function(src)
        return exports['oxide-death']:IsPlayerDead(src) == true
    end,

    ---@param src number
    ---@return table|nil
    GetDeathState = function(src)
        return exports['oxide-death']:GetDeathState(src)
    end,

    ---@param src number
    ---@param reviverSrc number|nil
    ---@return boolean
    RevivePlayer = function(src, reviverSrc)
        return exports['oxide-death']:RevivePlayer(src, reviverSrc) == true
    end,

    ---@param src number
    ---@param cause string|nil
    ---@return boolean
    KillPlayer = function(src, cause)
        return exports['oxide-death']:KillPlayer(src, cause) == true
    end,

    ---@param src number
    ---@param coords vector4|nil
    ---@return boolean
    RespawnPlayer = function(src, coords)
        return exports['oxide-death']:RespawnPlayer(src, coords) == true
    end,

    ---@param src number
    ---@param cause string|nil
    ---@param coords vector3|nil
    ---@param heading number|nil
    ---@return boolean
    DownPlayer = function(src, cause, coords, heading)
        return exports['oxide-death']:DownPlayer(src, cause, coords, heading) == true
    end,
})

AddEventHandler('oxide:death:stateChanged', function(src, oldState, newState, deathData)
    local data = {
        cause = deathData and deathData.causeOfDeath or nil,
        coords = deathData and deathData.position or nil,
    }
    TriggerEvent('olink:server:playerDeathStateChanged', src, newState, oldState, data)
end)

AddEventHandler('oxide:death:died', function(src)
    TriggerEvent('olink:server:playerDied', src, {})
end)

AddEventHandler('oxide:death:downed', function(src, causeOfDeath, coords)
    TriggerEvent('olink:server:playerDowned', src, { cause = causeOfDeath, coords = coords })
end)

AddEventHandler('oxide:death:revived', function(src, reviverSource)
    TriggerEvent('olink:server:playerRevived', src, { attacker = reviverSource })
end)

AddEventHandler('oxide:death:respawned', function(src, hospitalCoords)
    TriggerEvent('olink:server:playerRespawned', src, { coords = hospitalCoords })
end)
