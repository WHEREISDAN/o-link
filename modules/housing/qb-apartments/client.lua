local APARTMENTS = 'qb-apartments'
local HOUSES = 'qb-houses'

if GetResourceState(APARTMENTS) == 'missing' and GetResourceState(HOUSES) == 'missing' then return end
if not olink._guardImpl('Housing', APARTMENTS, false) then return end

olink._register('housing', {
    GetResourceName = function()
        if GetResourceState(APARTMENTS) == 'started' then return APARTMENTS end
        if GetResourceState(HOUSES) == 'started' then return HOUSES end
        return APARTMENTS
    end,
})
