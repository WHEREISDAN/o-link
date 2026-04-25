-- Default notify fallback (client).
-- Uses native GTA notification when no notify resource is running.

if not olink._guardNotifyAdapter('_default', false) then return end

local function Send(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(tostring(message or ''))
    EndTextCommandThefeedPostTicker(false, true)
end

olink._registerDefault('notify', {
    Send = function(message, _notifType, _duration, _title, _props) Send(message) end,
}, '_default')
