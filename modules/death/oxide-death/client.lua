if not olink._guardImpl('Death', 'oxide-death', 'oxide-death') then return end

olink._register('death', {
    ---@return boolean
    IsPlayerDowned = function()
        return exports['oxide-death']:IsLocalPlayerDowned() == true
    end,

    ---@return boolean
    IsPlayerDead = function()
        return exports['oxide-death']:IsLocalPlayerDead() == true
    end,

    ---@return table|nil
    GetDeathState = function()
        return exports['oxide-death']:GetLocalDeathState()
    end,
})

RegisterNetEvent('oxide:death:stateChanged', function(_, oldState, newState, deathData)
    local data = {
        cause = deathData and deathData.causeOfDeath or nil,
        coords = deathData and deathData.position or nil,
    }

    if newState == 'dead' then
        if oldState == 'downed' then
            TriggerEvent('olink:client:playerDied', data)
        elseif oldState == 'alive' then
            TriggerEvent('olink:client:playerDied', data)
        end
    elseif newState == 'downed' then
        TriggerEvent('olink:client:playerDowned', data)
    elseif newState == 'alive' then
        if oldState == 'dead' then
            TriggerEvent('olink:client:playerRespawned', data)
        else
            TriggerEvent('olink:client:playerRevived', data)
        end
    end
    TriggerEvent('olink:client:playerDeathStateChanged', newState, oldState, data)
end)
