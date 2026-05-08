-- Default death fallback (client).

if not olink._guardImpl('Death', '_default', false) then return end
if not olink._hasOverride('Death') and GetResourceState('es_extended') == 'started' then return end
if not olink._hasOverride('Death') and GetResourceState('qb-core') == 'started' then return end
if not olink._hasOverride('Death') and GetResourceState('qbx_core') == 'started' then return end
if not olink._hasOverride('Death') and GetResourceState('oxide-core') == 'started' then return end
if not olink._hasOverride('Death') and GetResourceState('oxide-death') == 'started' then return end

olink._registerDefault('death', {
    GetResourceName = function() return '_default' end,
    IsPlayerDowned = function() return false end,
    IsPlayerDead = function() return IsPedDeadOrDying(PlayerPedId(), true) end,
    GetDeathState = function() return nil end,
})

CreateThread(function()
    local lastState = 'alive'
    while true do
        Wait(500)
        local newState = IsPedDeadOrDying(PlayerPedId(), true) and 'dead' or 'alive'
        if newState ~= lastState then
            local oldState = lastState
            lastState = newState

            if newState == 'dead' then
                TriggerEvent('olink:client:playerDied', {})
                TriggerServerEvent('olink:_default:death', true)
            else
                TriggerEvent('olink:client:playerRevived', {})
                TriggerServerEvent('olink:_default:death', false)
            end
            TriggerEvent('olink:client:playerDeathStateChanged', newState, oldState, {})
        end
    end
end)
