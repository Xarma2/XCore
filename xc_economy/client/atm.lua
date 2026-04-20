local atmOpen = false

local atmLocations = {
    vector3(149.4, -1042.9, 29.4),
    vector3(-1393.8, -585.5, 30.0),
    vector3(314.2, -279.1, 54.2),
    vector3(-2963.5, 482.9, 15.7),
    vector3(1175.0, 2706.5, 38.1),
}

RegisterNetEvent('xc_economy:openATM', function()
    if atmOpen then return end
    atmOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action='openATM' })
end)

RegisterNUICallback('xc_economy:closeATM', function(data, cb)
    atmOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('xc_economy:deposit', function(data, cb)
    exports['xc_core']:TriggerCallback('xc_economy:deposit', { amount = tonumber(data.amount) }, function(res)
        cb(res)
        if res and res.success then
            TriggerEvent('xc_notify:send', { type='success', msg='Deposito effettuato: ' .. XCoreUtils.FormatMoney(data.amount) })
        else
            TriggerEvent('xc_notify:send', { type='error', msg=res and res.error or 'Errore' })
        end
    end)
end)

RegisterNUICallback('xc_economy:withdraw', function(data, cb)
    exports['xc_core']:TriggerCallback('xc_economy:withdraw', { amount = tonumber(data.amount) }, function(res)
        cb(res)
        if res and res.success then
            TriggerEvent('xc_notify:send', { type='success', msg='Prelievo effettuato: ' .. XCoreUtils.FormatMoney(data.amount) })
        else
            TriggerEvent('xc_notify:send', { type='error', msg=res and res.error or 'Saldo insufficiente' })
        end
    end)
end)

RegisterNUICallback('xc_economy:transfer', function(data, cb)
    exports['xc_core']:TriggerCallback('xc_economy:transfer', {
        toCharId = tonumber(data.toCharId),
        amount   = tonumber(data.amount),
        note     = data.note,
    }, function(res)
        cb(res)
        if res and res.success then
            TriggerEvent('xc_notify:send', { type='success', msg='Bonifico inviato: ' .. XCoreUtils.FormatMoney(data.amount) })
        else
            TriggerEvent('xc_notify:send', { type='error', msg=res and res.error or 'Errore nel bonifico' })
        end
    end)
end)

RegisterNUICallback('xc_economy:getBalance', function(data, cb)
    exports['xc_core']:TriggerCallback('xc_economy:getBalance', {}, function(res)
        cb(res)
    end)
end)

RegisterNUICallback('xc_economy:getTransactions', function(data, cb)
    exports['xc_core']:TriggerCallback('xc_economy:getTransactions', {}, function(res)
        cb(res or {})
    end)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped    = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for _, atm in ipairs(atmLocations) do
            local dist = #(coords - atm)
            if dist < 20.0 then
                DrawMarker(20, atm.x, atm.y, atm.z - 0.95, 0,0,0, 0,0,0, 0.5,0.5,0.5, 0,170,255, 80, false, true, 2, false, nil, nil, false)
                if dist < 1.5 then
                    TriggerEvent('xc_notify:send', { type='info', msg='Premi ~INPUT_CONTEXT~ per usare il bancomat', duration=1000 })
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('xc_economy:openATM')
                        TriggerEvent('xc_economy:openATM')
                    end
                end
            end
        end
    end
end)
