-- Default doorlock fallback (client).

if not olink._guardImpl('Doorlock', '_default', false) then return end
if not olink._hasOverride('Doorlock') and GetResourceState('doors_creator') == 'started' then return end
if not olink._hasOverride('Doorlock') and GetResourceState('ox_doorlock') == 'started' then return end
if not olink._hasOverride('Doorlock') and GetResourceState('qb-doorlock') == 'started' then return end
if not olink._hasOverride('Doorlock') and GetResourceState('rcore_doorlock') == 'started' then return end

olink._registerDefault('doorlock', olink._buildStub('doorlock', {
    'GetClosestDoor',
}))

olink._registerDefault('doorlock', {
    GetResourceName = function() return '_default' end,
})
