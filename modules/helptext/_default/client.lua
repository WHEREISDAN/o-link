-- Default helptext fallback (client).
-- Uses native BeginTextCommandDisplayHelp when no helptext resource is running.

if not olink._guardImpl('HelpText', '_default', false) then return end
if not olink._hasOverride('HelpText') and GetResourceState('cd_drawtextui') == 'started' then return end
if not olink._hasOverride('HelpText') and GetResourceState('jg-textui') == 'started' then return end
if not olink._hasOverride('HelpText') and GetResourceState('lab-HintUI') == 'started' then return end
if not olink._hasOverride('HelpText') and GetResourceState('lation_ui') == 'started' then return end
if not olink._hasOverride('HelpText') and GetResourceState('okokTextUI') == 'started' then return end
if not olink._hasOverride('HelpText') and GetResourceState('ox_lib') == 'started' then return end
if not olink._hasOverride('HelpText') and GetResourceState('ZSX_UIV2') == 'started' then return end
if not olink._hasOverride('HelpText') and GetResourceState('zsxui') == 'started' then return end

local visible = false

local function Show(message)
    visible = true
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(tostring(message or ''))
    EndTextCommandDisplayHelp(0, false, true, -1)
end

local function Hide()
    visible = false
    ClearAllHelpMessages()
end

olink._registerDefault('helptext', {
    GetResourceName = function() return '_default' end,
    Show = function(message, _position) Show(message) end,
    Hide = Hide,
})

RegisterNetEvent('o-link:client:helptextShow', function(message, position)
    Show(message)
end)

RegisterNetEvent('o-link:client:helptextHide', function()
    Hide()
end)
