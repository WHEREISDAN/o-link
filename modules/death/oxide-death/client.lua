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

    ---Suspend/resume the local death detection (scene/admin tools that manipulate
    ---the player ped mid-session). Returns true when the provider honoured it —
    ---callers must treat false as "not supported" and rely on their own backstop
    ---(e.g. invincibility).
    ---@param value boolean
    ---@return boolean
    SetSuppressed = function(value)
        return exports['oxide-death']:SetDeathSuppressed(value == true) == true
    end,
})

-- TriggerClientEvent('oxide:death:stateChanged', src, oldState, newState, data)
-- arrives WITHOUT the src argument — only the server-side TriggerEvent carries
-- it. The old `(_, oldState, newState, deathData)` signature here shifted every
-- argument by one, so newState held the data TABLE and no state comparison
-- below ever matched: none of the olink:client death events fired on oxide-death.
RegisterNetEvent('oxide:death:stateChanged', function(oldState, newState, deathData)
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
