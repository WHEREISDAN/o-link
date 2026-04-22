-- Default framework fallback.
-- Loads when no dedicated framework is running (standalone / lobby).

if not olink._guardImpl('Framework', '_default', false) then return end
if not olink._hasOverride('Framework') and GetResourceState('es_extended') == 'started' then return end
if not olink._hasOverride('Framework') and GetResourceState('qb-core') == 'started' then return end
if not olink._hasOverride('Framework') and GetResourceState('qbx_core') == 'started' then return end
if not olink._hasOverride('Framework') and GetResourceState('oxide-core') == 'started' then return end

local function getLicense(src)
    if not src then return nil end
    return GetPlayerIdentifierByType(src, 'license2') or GetPlayerIdentifierByType(src, 'license')
end

olink._registerDefault('framework', {
    GetResourceName = function() return '_default' end,
    GetName = function() return '_default' end,
    GetIsPlayerLoaded = function() return false end,
    GetPlayers = function() return GetPlayers() end,
    GetJobs = function() return {} end,
    IsAdmin = function() return false end,
    Logout = function() return false end,
    GetPlayerInventory = function() return {} end,

    RegisterUsableItem = function(itemName)
        print(('^3[o-link] framework/_default: RegisterUsableItem("%s") — no framework loaded, item will not be usable.^0'):format(tostring(itemName)))
    end,

    GetPlayerIdentifier = function(src) return getLicense(src) end,
})
