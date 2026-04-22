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
