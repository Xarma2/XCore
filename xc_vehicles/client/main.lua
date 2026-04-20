local currentVehicle = nil
local currentPlate   = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            if veh ~= currentVehicle then
                currentVehicle = veh
                currentPlate   = GetVehicleNumberPlateText(veh):gsub('%s+', '')
                TriggerEvent('xc_vehicles:enteredVehicle', veh, currentPlate)
            end
        else
            if currentVehicle then
                TriggerEvent('xc_vehicles:leftVehicle', currentVehicle, currentPlate)
                currentVehicle = nil
                currentPlate   = nil
            end
        end
    end
end)

RegisterNetEvent('xc_vehicles:saveOnDisconnect', function()
    if currentVehicle and DoesEntityExist(currentVehicle) then
        local plate = GetVehicleNumberPlateText(currentVehicle):gsub('%s+', '')
        SaveCurrentVehicle(plate)
    end
end)

function SaveCurrentVehicle(plate)
    if not currentVehicle or not DoesEntityExist(currentVehicle) then return end
    exports['xc_core']:TriggerCallback('xc_vehicles:storeVehicle', {
        plate  = plate,
        fuel   = GetVehicleFuelLevel(currentVehicle),
        body   = GetVehicleBodyHealth(currentVehicle),
        engine = GetVehicleEngineHealth(currentVehicle),
    }, function(res) end)
end

RegisterNetEvent('xc_vehicles:requestCurrentPlate', function(target)
    if currentPlate then
        TriggerServerEvent('xc_vehicles:server:giveKeysToTarget', currentPlate, target)
    else
        TriggerEvent('xc_notify:send', { type='error', msg='Non sei in un veicolo.' })
    end
end)

exports('GetCurrentVehicle', function() return currentVehicle end)
exports('GetCurrentPlate',   function() return currentPlate end)
