-- Default bossmenu fallback.
-- Loads when no dedicated boss menu resource is running.

if not olink._guardImpl('BossMenu', '_default', false) then return end
if not olink._hasOverride('BossMenu') and GetResourceState('esx_society') == 'started' then return end
if not olink._hasOverride('BossMenu') and GetResourceState('qb-management') == 'started' then return end
if not olink._hasOverride('BossMenu') and GetResourceState('qbx_management') == 'started' then return end

olink._registerDefault('bossmenu', olink._buildStub('bossmenu', {
    'OpenBossMenu',
}))

olink._registerDefault('bossmenu', {
    GetResourceName = function() return '_default' end,
})
