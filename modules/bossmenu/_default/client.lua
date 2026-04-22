-- Default bossmenu fallback (client).

if not olink._guardImpl('BossMenu', '_default', false) then return end
if not olink._hasOverride('BossMenu') and GetResourceState('esx_society') == 'started' then return end
if not olink._hasOverride('BossMenu') and GetResourceState('qb-management') == 'started' then return end
if not olink._hasOverride('BossMenu') and GetResourceState('qbx_management') == 'started' then return end

olink._registerDefault('bossmenu', {
    GetResourceName = function() return '_default' end,
})
