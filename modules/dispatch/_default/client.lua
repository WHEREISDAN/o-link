-- Default dispatch fallback client.
-- Provides SendAlert that fires a server event, and receives alerts as notifications + blips.

if not olink._guardImpl('Dispatch', '_default', false) then return end
if not olink._hasOverride('Dispatch') and GetResourceState('oxide-dispatch') == 'started' then return end
if not olink._hasOverride('Dispatch') and GetResourceState('ps-dispatch') == 'started' then return end
if not olink._hasOverride('Dispatch') and GetResourceState('cd_dispatch') == 'started' then return end
if not olink._hasOverride('Dispatch') and GetResourceState('lb-tablet') == 'started' then return end
if not olink._hasOverride('Dispatch') and GetResourceState('bub-mdt') == 'started' then return end
if not olink._hasOverride('Dispatch') and GetResourceState('emergencydispatch') == 'started' then return end
if not olink._hasOverride('Dispatch') and GetResourceState('qs_dispatch') == 'started' then return end
if not olink._hasOverride('Dispatch') and GetResourceState('tk_dispatch') == 'started' then return end
if not olink._hasOverride('Dispatch') and GetResourceState('fd_dispatch') == 'started' then return end
if not olink._hasOverride('Dispatch') and GetResourceState('kartik-mdt') == 'started' then return end
if not olink._hasOverride('Dispatch') and GetResourceState('linden_outlawalert') == 'started' then return end
if not olink._hasOverride('Dispatch') and GetResourceState('origen_police') == 'started' then return end
if not olink._hasOverride('Dispatch') and GetResourceState('piotreq_gpt') == 'started' then return end
if not olink._hasOverride('Dispatch') and GetResourceState('redutzu-mdt') == 'started' then return end
if not olink._hasOverride('Dispatch') and GetResourceState('wasabi_mdt') == 'started' then return end

olink._register('dispatch', {
    GetResourceName = function() return '_default' end,

    ---@param data table
    SendAlert = function(data)
        local ped = PlayerPedId()
        TriggerServerEvent('o-link:dispatch:default:sendAlert', {
            sprite    = data.blipData and data.blipData.sprite or 161,
            color     = data.blipData and data.blipData.color or 84,
            scale     = data.blipData and data.blipData.scale or 1.0,
            coords    = data.coords or GetEntityCoords(ped),
            message   = data.message or 'Alert',
            code      = data.code or '10-80',
            icon      = data.icon or 'fas fa-question',
            jobs      = data.jobs or { 'police' },
            time      = data.time or 30000,
            blipData  = data.blipData,
        })
    end,
})

RegisterNetEvent('o-link:dispatch:default:alert', function(data)
    if olink.notify then
        olink.notify.Send(('[%s] %s'):format(data.code or '10-80', data.message or 'Alert'), 'warning', 15000)
    end

    if data.coords then
        local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(blip, data.sprite or 161)
        SetBlipColour(blip, data.color or 84)
        SetBlipScale(blip, data.scale or 1.0)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(data.code or '10-80')
        EndTextCommandSetBlipName(blip)

        local timeout = data.time or 30000
        SetTimeout(timeout, function()
            if DoesBlipExist(blip) then RemoveBlip(blip) end
        end)
    end
end)
