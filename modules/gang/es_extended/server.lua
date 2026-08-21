if not olink._guardImpl('Gang', 'es_extended', 'es_extended') then return end
if not olink._hasOverride('Gang') and GetResourceState('oxide-gangs') ~= 'missing' then return end
if not olink._hasOverride('Gang') and GetResourceState('oxide-core') == 'started' then return end
if not olink._hasOverride('Gang') and GetResourceState('qb-core') == 'started' then return end
if not olink._hasOverride('Gang') and GetResourceState('qbx_core') == 'started' then return end

-- ESX has no native gang system — stub implementation
olink._register('gang', {
    Get = function(src) return nil end,
    Set = function(...) return false end,
})
