if not olink._guardImpl('Death', 'qbx_core', 'qbx_core') then return end
if not olink._hasOverride('Death') and GetResourceState('oxide-death') == 'started' then return end

olink._register('death', {
    ---@return boolean
    IsPlayerDowned = function()
        local data = exports.qbx_core:GetPlayerData()
        if not data or not data.metadata then return false end
        return data.metadata.inlaststand == true
    end,

    ---@return boolean
    IsPlayerDead = function()
        local data = exports.qbx_core:GetPlayerData()
        if not data or not data.metadata then return false end
        return data.metadata.isdead == true
    end,

    ---@return table|nil
    GetDeathState = function()
        local data = exports.qbx_core:GetPlayerData()
        if not data or not data.metadata then return nil end
        local state = 'alive'
        if data.metadata.isdead then state = 'dead'
        elseif data.metadata.inlaststand then state = 'downed' end
        return { state = state }
    end,
})

local lastState = 'alive'

local function transitionTo(newState, data)
    if newState == lastState then return end
    local oldState = lastState
    lastState = newState
    data = data or {}

    if newState == 'dead' then
        TriggerEvent('olink:client:playerDied', data)
    elseif newState == 'downed' then
        TriggerEvent('olink:client:playerDowned', data)
    elseif newState == 'alive' then
        TriggerEvent('olink:client:playerRevived', data)
    end
    TriggerEvent('olink:client:playerDeathStateChanged', newState, oldState, data)
end

RegisterNetEvent('qbx_medical:client:onPlayerDied', function(attacker, weapon)
    transitionTo('dead', { attacker = attacker, weapon = weapon })
end)

RegisterNetEvent('qbx_medical:client:onPlayerLaststand', function(attacker, weapon)
    transitionTo('downed', { attacker = attacker, weapon = weapon })
end)

RegisterNetEvent('qbx_medical:client:playerRevived', function()
    transitionTo('alive', {})
end)
