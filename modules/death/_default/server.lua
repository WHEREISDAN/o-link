-- Default death fallback.
-- Mirrors community_bridge/framework/_default death state stubs.

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
