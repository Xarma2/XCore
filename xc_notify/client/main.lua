local function SendNotify(data)
    SendNUIMessage({
        action   = 'notify',
        type     = data.type     or 'info',
        msg      = data.msg      or '',
        duration = data.duration or 3000,
        title    = data.title,
    })
end

AddEventHandler('xc_notify:send', function(data)
    SendNotify(data)
end)

RegisterNetEvent('xc_notify:send', function(data)
    SendNotify(data)
end)

exports('Send', SendNotify)
