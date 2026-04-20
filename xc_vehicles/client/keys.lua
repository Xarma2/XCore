local ownedKeys = {}  

function HasVehicleKeys(plate)
    return ownedKeys[plate] == true
end

RegisterNetEvent('xc_vehicles:receiveKeys', function(plate)
    ownedKeys[plate] = true
    TriggerEvent('xc_vehicles:keysReceived', plate)
end)

RegisterNetEvent('xc_vehicles:removeKeys', function(plate)
    ownedKeys[plate] = nil
    TriggerEvent('xc_vehicles:keysRemoved', plate)
end)

AddEventHandler('xc_vehicles:enteredVehicle', function(veh, plate)
    if not HasVehicleKeys(plate) then
        
        exports['xc_core']:TriggerCallback('xc_vehicles:checkOwnership', { plate=plate }, function(isOwner)
            if isOwner then
                ownedKeys[plate] = true
            end
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 311) then  
            local ped   = PlayerPedId()
            local plate = exports['xc_vehicles']:GetCurrentPlate()
            if not plate then
                
                local coords = GetEntityCoords(ped)
                local veh = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 70)
                if veh and veh ~= 0 then
                    plate = GetVehicleNumberPlateText(veh):gsub('%s+', '')
                end
            end
            if plate and HasVehicleKeys(plate) then
                local veh = GetClosestVehicle(GetEntityCoords(ped).x, GetEntityCoords(ped).y, GetEntityCoords(ped).z, 5.0, 0, 70)
                if veh and veh ~= 0 then
                    local locked = GetVehicleDoorLockStatus(veh)
                    if locked == 1 then
                        SetVehicleDoorsLocked(veh, 2)
                        TriggerEvent('xc_notify:send', { type='info', msg='Veicolo bloccato.', duration=1500 })
                    else
                        SetVehicleDoorsLocked(veh, 1)
                        TriggerEvent('xc_notify:send', { type='info', msg='Veicolo sbloccato.', duration=1500 })
                    end
                end
            end
        end
    end
end)

exports('HasVehicleKeys', HasVehicleKeys)
exports('GetOwnedKeys',   function() return ownedKeys end)
