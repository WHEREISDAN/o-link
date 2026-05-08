-- Default death fallback.

if not olink._guardImpl('Death', '_default', false) then return end
if not olink._hasOverride('Death') and GetResourceState('es_extended') == 'started' then return end
if not olink._hasOverride('Death') and GetResourceState('qb-core') == 'started' then return end
if not olink._hasOverride('Death') and GetResourceState('qbx_core') == 'started' then return end
if not olink._hasOverride('Death') and GetResourceState('oxide-core') == 'started' then return end
if not olink._hasOverride('Death') and GetResourceState('oxide-death') == 'started' then return end

olink._registerDefault('death', {
    GetResourceName = function() return '_default' end,

    IsPlayerDowned = function() return false end,
    IsPlayerDead = function() return false end,
    GetDeathState = function() return nil end,
    RevivePlayer = function() return false end,
    KillPlayer = function() return false end,
    RespawnPlayer = function() return false end,
    DownPlayer = function() return false end,
})

local lastState = {}

RegisterNetEvent('olink:_default:death', function(isDead)
    local src = source
    if not src or src <= 0 then return end

    local newState = isDead and 'dead' or 'alive'
    local oldState = lastState[src] or 'alive'
    if newState == oldState then return end
    lastState[src] = newState

    if newState == 'dead' then
        TriggerEvent('olink:server:playerDied', src, {})
    else
        TriggerEvent('olink:server:playerRevived', src, {})
    end
    TriggerEvent('olink:server:playerDeathStateChanged', src, newState, oldState, {})
end)

AddEventHandler('playerDropped', function()
    local src = source
    lastState[src] = nil
end)
