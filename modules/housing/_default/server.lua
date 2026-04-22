-- Default housing fallback.

if not olink._guardImpl('Housing', '_default', false) then return end
if not olink._hasOverride('Housing') and GetResourceState('bcs-housing') == 'started' then return end
if not olink._hasOverride('Housing') and GetResourceState('esx_property') == 'started' then return end
if not olink._hasOverride('Housing') and GetResourceState('ps-housing') == 'started' then return end
if not olink._hasOverride('Housing') and GetResourceState('qb-appartments') == 'started' then return end
if not olink._hasOverride('Housing') and GetResourceState('qb-houses') == 'started' then return end

olink._registerDefault('housing', {
    GetResourceName = function() return '_default' end,
})
