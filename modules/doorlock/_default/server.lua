-- Default doorlock fallback.

if not olink._guardImpl('Doorlock', '_default', false) then return end
if not olink._hasOverride('Doorlock') and GetResourceState('doors_creator') == 'started' then return end
if not olink._hasOverride('Doorlock') and GetResourceState('ox_doorlock') == 'started' then return end
if not olink._hasOverride('Doorlock') and GetResourceState('qb-doorlock') == 'started' then return end
if not olink._hasOverride('Doorlock') and GetResourceState('rcore_doorlock') == 'started' then return end

olink._registerDefault('doorlock', olink._buildStub('doorlock', {
    'ToggleDoorLock',
}, {
    ToggleDoorLock = false,
}))

olink._registerDefault('doorlock', {
    GetResourceName = function() return '_default' end,
})
