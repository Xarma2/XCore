local garageOpen = false

RegisterNetEvent('xc_vehicles:openGarage', function(garageName)
    if garageOpen then return end
    exports['xc_core']:TriggerCallback('xc_vehicles:getMyVehicles', {}, function(vehicles)
        garageOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            action   = 'openGarage',
            vehicles = vehicles or {},
            garage   = garageName,
        })
    end)
end)

RegisterNUICallback('xc_vehicles:closeGarage', function(data, cb)
    garageOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('xc_vehicles:spawnVehicle', function(data, cb)
    exports['xc_core']:TriggerCallback('xc_vehicles:spawnVehicle', { plate=data.plate }, function(res)
        cb(res)
        if res and res.success then
            SpawnVehicleAtCoords(res.vehicle, res.spawn)
            garageOpen = false
            SetNuiFocus(false, false)
        else
            TriggerEvent('xc_notify:send', { type='error', msg=res and res.error or 'Errore' })
        end
    end)
end)

RegisterNUICallback('xc_vehicles:storeVehicle', function(data, cb)
    local veh = exports['xc_vehicles']:GetCurrentVehicle()
    local plate = exports['xc_vehicles']:GetCurrentPlate()
    if not veh or not plate then
        TriggerEvent('xc_notify:send', { type='error', msg='Non sei in un veicolo.' })
        return cb({ success=false })
    end
    exports['xc_core']:TriggerCallback('xc_vehicles:storeVehicle', {
        plate  = plate,
        fuel   = GetVehicleFuelLevel(veh),
        body   = GetVehicleBodyHealth(veh),
        engine = GetVehicleEngineHealth(veh),
        garage = data.garage,
    }, function(res)
        cb(res)
        if res and res.success then
            DeleteEntity(veh)
            TriggerEvent('xc_notify:send', { type='success', msg='Veicolo parcheggiato.' })
        end
    end)
end)

function SpawnVehicleAtCoords(vehData, spawnCoords)
    local model = GetHashKey(vehData.model)
    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 5000 do
        Citizen.Wait(100)
        timeout = timeout + 100
    end
    if not HasModelLoaded(model) then
        TriggerEvent('xc_notify:send', { type='error', msg='Modello veicolo non trovato.' })
        return
    end

    local veh = CreateVehicle(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.heading, true, false)
    SetVehicleNumberPlateText(veh, vehData.plate)
    SetVehicleFuelLevel(veh, vehData.fuel or 100.0)
    SetVehicleBodyHealth(veh, vehData.body or 1000.0)
    SetVehicleEngineHealth(veh, vehData.engine or 1000.0)
    SetEntityAsMissionEntity(veh, true, true)
    SetPedIntoVehicle(PlayerPedId(), veh, -1)

    
    if vehData.mods then
        local mods = XCoreUtils.SafeDecode(vehData.mods) or {}
        SetVehicleModKit(veh, 0)
        for modType, modIndex in pairs(mods) do
            SetVehicleMod(veh, tonumber(modType), modIndex, false)
        end
    end

    
    TriggerEvent('xc_vehicles:receiveKeys', vehData.plate)
    SetModelAsNoLongerNeeded(model)

    TriggerEvent('xc_notify:send', { type='success', msg='Veicolo spawned.' })
    return veh
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped    = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for gName, garage in pairs(XCoreConfig.Garages) do
            local dist = #(coords - garage.coords)
            if dist < 30.0 then
                DrawMarker(20, garage.coords.x, garage.coords.y, garage.coords.z - 0.95, 0,0,0, 0,0,0, 1.0,1.0,0.5, 0,170,255,80, false, true, 2, false, nil, nil, false)
                if dist < 2.0 then
                    TriggerEvent('xc_notify:send', { type='info', msg='Premi ~INPUT_CONTEXT~ per aprire il garage', duration=1000 })
                    if IsControlJustReleased(0, 38) then
                        TriggerEvent('xc_vehicles:openGarage', gName)
                        TriggerNetEvent('xc_vehicles:openGarage', gName)
                    end
                end
            end
        end
    end
end)
