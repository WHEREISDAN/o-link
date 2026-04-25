RegisterNetEvent('o-link:client:notify', function(message, notifType, duration, title, props)
    if olink.notify and type(olink.notify.Send) == 'function' then
        olink.notify.Send(message, notifType, duration, title, props)
    end
end)
