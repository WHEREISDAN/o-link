-- Default framework fallback (client).

if not olink._guardImpl('Framework', '_default', false) then return end
if not olink._hasOverride('Framework') and GetResourceState('es_extended') == 'started' then return end
if not olink._hasOverride('Framework') and GetResourceState('qb-core') == 'started' then return end
if not olink._hasOverride('Framework') and GetResourceState('qbx_core') == 'started' then return end
if not olink._hasOverride('Framework') and GetResourceState('oxide-core') == 'started' then return end

olink._registerDefault('framework', {
    GetResourceName = function() return '_default' end,
    GetName = function() return '_default' end,
    GetIsPlayerLoaded = function() return false end,
    ShowHelpText = function(message, position)
        BeginTextCommandDisplayHelp('STRING')
        AddTextComponentSubstringPlayerName(tostring(message or ''))
        EndTextCommandDisplayHelp(0, false, true, -1)
    end,
    HideHelpText = function()
        ClearAllHelpMessages()
    end,
    IsAdmin = function() return false end,
})
