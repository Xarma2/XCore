exports('GiveKeys', function(source, plate)
    TriggerClientEvent('xc_vehicles:receiveKeys', source, plate)
end)

exports('RemoveKeys', function(source, plate)
    TriggerClientEvent('xc_vehicles:removeKeys', source, plate)
end)

AddEventHandler('xc_core:playerLoaded', function(source, player)
    
end)

RegisterCommand('givekeys', function(source, args)
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return end
    local target = tonumber(args[1])
    if not target then
        TriggerClientEvent('xc_notify:send', source, { type='error', msg='Uso: /givekeys [id]' })
        return
    end
    
    TriggerClientEvent('xc_vehicles:requestCurrentPlate', source, target)
end, false)

RegisterNetEvent('xc_vehicles:server:giveKeysToTarget', function(plate, target)
    local source = source
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return end
    local veh = exports['xc_vehicles']:GetVehicleByPlate(plate)
    if not veh or veh.char_id ~= player.charId then
        TriggerClientEvent('xc_notify:send', source, { type='error', msg='Non è il tuo veicolo.' })
        return
    end
    exports['xc_vehicles']:GiveKeys(target, plate)
    TriggerClientEvent('xc_notify:send', source, { type='success', msg='Chiavi consegnate.' })
    TriggerClientEvent('xc_notify:send', target, { type='success', msg='Hai ricevuto le chiavi di un veicolo.' })
end)
