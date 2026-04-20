local spawnedVehicles = {}

exports('GetVehicles', function(charId)
    return exports.oxmysql:executeSync(
        'SELECT * FROM xcore_vehicles WHERE char_id = ? ORDER BY id', { charId }
    ) or {}
end)

exports('GetVehicleByPlate', function(plate)
    local rows = exports.oxmysql:executeSync(
        'SELECT * FROM xcore_vehicles WHERE plate = ? LIMIT 1', { plate }
    )
    return rows and rows[1] or nil
end)

exports('BuyVehicle', function(source, model, label, garage)
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return false, 'Player non trovato' end

    local plate = XCoreUtils.GeneratePlate()
    
    local attempts = 0
    while attempts < 10 do
        local existing = exports['xc_vehicles']:GetVehicleByPlate(plate)
        if not existing then break end
        plate = XCoreUtils.GeneratePlate()
        attempts = attempts + 1
    end

    local vehId = exports.oxmysql:executeSync(
        'INSERT INTO xcore_vehicles (char_id, plate, model, label, garage, state) VALUES (?,?,?,?,?,0)',
        { player.charId, plate, model, label or model, garage or 'pillbox' }
    )
    return true, vehId
end)

exports('SaveVehicle', function(plate, data)
    exports.oxmysql:execute(
        'UPDATE xcore_vehicles SET fuel=?, body=?, engine=?, mods=?, garage=?, state=? WHERE plate=?',
        { data.fuel, data.body, data.engine, json.encode(data.mods or {}), data.garage, data.state or 0, plate }
    )
end)

exports('ImpoundVehicle', function(plate)
    exports.oxmysql:execute(
        'UPDATE xcore_vehicles SET state=2, garage=? WHERE plate=?', { 'impound', plate }
    )
end)

exports['xc_core']:RegisterCallback('xc_vehicles:getMyVehicles', function(source, data, resolve)
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return resolve({}) end
    resolve(exports['xc_vehicles']:GetVehicles(player.charId))
end)

exports['xc_core']:RegisterCallback('xc_vehicles:spawnVehicle', function(source, data, resolve)
    if not data or not data.plate then return resolve({ success=false }) end
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return resolve({ success=false }) end

    local veh = exports['xc_vehicles']:GetVehicleByPlate(data.plate)
    if not veh or veh.char_id ~= player.charId then
        return resolve({ success=false, error='Veicolo non trovato' })
    end
    if veh.state == 1 then
        return resolve({ success=false, error='Veicolo già in giro' })
    end

    
    exports.oxmysql:execute('UPDATE xcore_vehicles SET state=1 WHERE plate=?', { data.plate })

    
    local garageData = XCoreConfig.Garages[veh.garage] or XCoreConfig.Garages.pillbox
    local spawn = garageData.spawn

    resolve({
        success = true,
        vehicle = veh,
        spawn   = { x=spawn.x, y=spawn.y, z=spawn.z, heading=spawn.w },
    })
end)

exports['xc_core']:RegisterCallback('xc_vehicles:storeVehicle', function(source, data, resolve)
    if not data or not data.plate then return resolve({ success=false }) end
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return resolve({ success=false }) end

    local veh = exports['xc_vehicles']:GetVehicleByPlate(data.plate)
    if not veh or veh.char_id ~= player.charId then
        return resolve({ success=false, error='Non è il tuo veicolo' })
    end

    exports['xc_vehicles']:SaveVehicle(data.plate, {
        fuel   = data.fuel   or veh.fuel,
        body   = data.body   or veh.body,
        engine = data.engine or veh.engine,
        mods   = data.mods   or {},
        garage = data.garage or veh.garage,
        state  = 0,
    })

    resolve({ success=true })
end)

AddEventHandler('xc_core:playerDropped', function(source, player)
    TriggerClientEvent('xc_vehicles:saveOnDisconnect', source)
end)

XCoreUtils.Log('vehicles', 'Vehicles module avviato')
