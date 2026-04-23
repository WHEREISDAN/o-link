-- Default notify fallback (client).
-- Uses native GTA notification when no notify resource is running.

if not olink._guardImpl('Notify', '_default', false) then return end
if not olink._hasOverride('Notify') and GetResourceState('brutal_notify') == 'started' then return end
if not olink._hasOverride('Notify') and GetResourceState('confirm') == 'started' then return end
if not olink._hasOverride('Notify') and GetResourceState('fl-notify') == 'started' then return end
if not olink._hasOverride('Notify') and GetResourceState('lation_ui') == 'started' then return end
if not olink._hasOverride('Notify') and GetResourceState('mythic_notify') == 'started' then return end
if not olink._hasOverride('Notify') and GetResourceState('okokNotify') == 'started' then return end
if not olink._hasOverride('Notify') and GetResourceState('ox_lib') == 'started' then return end
if not olink._hasOverride('Notify') and GetResourceState('oxide-notify') == 'started' then return end
if not olink._hasOverride('Notify') and GetResourceState('pNotify') == 'started' then return end
if not olink._hasOverride('Notify') and GetResourceState('r_notify') == 'started' then return end
if not olink._hasOverride('Notify') and GetResourceState('t-notify') == 'started' then return end
if not olink._hasOverride('Notify') and GetResourceState('wasabi_notify') == 'started' then return end
if not olink._hasOverride('Notify') and GetResourceState('ZSX_UIV2') == 'started' then return end
if not olink._hasOverride('Notify') and GetResourceState('zsxui') == 'started' then return end

local function Send(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(tostring(message or ''))
    EndTextCommandThefeedPostTicker(false, true)
end

olink._registerDefault('notify', {
    Send = function(message, _notifType, _duration, _title, _props) Send(message) end,
}, '_default')

RegisterNetEvent('o-link:client:notify', function(message)
    Send(message)
end)
