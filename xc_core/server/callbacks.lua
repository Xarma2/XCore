local callbacks = {}

function XCoreCallback(name, cb)
    callbacks[name] = cb
end

RegisterNetEvent('xc_core:server:triggerCallback', function(name, requestId, data)
    local source = source
    local cb = callbacks[name]
    if not cb then
        XCoreUtils.Log('core', ('Callback non registrato: %s'):format(name), 'warn')
        TriggerClientEvent('xc_core:client:callbackResponse', source, requestId, nil)
        return
    end

    
    local function resolve(result)
        TriggerClientEvent('xc_core:client:callbackResponse', source, requestId, result)
    end

    local ok, err = pcall(cb, source, data, resolve)
    if not ok then
        XCoreUtils.Log('core', ('Errore callback %s: %s'):format(name, err), 'error')
        TriggerClientEvent('xc_core:client:callbackResponse', source, requestId, nil)
    end
end)

exports('RegisterCallback', XCoreCallback)

XCoreCallback('xc_core:getPlayerData', function(source, data, resolve)
    local player = XCorePlayers[source]
    if not player then return resolve(nil) end
    resolve({
        charId   = player.charId,
        name     = player.name,
        job      = player.job,
        gang     = player.gang,
        money    = player.money,
        metadata = player.metadata,
        status   = player.status,
        group    = player.group,
        phone    = player.phone,
        isDead   = player.isDead,
    })
end)

XCoreCallback('xc_core:getCharacters', function(source, data, resolve)
    local identifier = GetPlayerIdentifier(source, 0)
    if not identifier then return resolve({}) end

    local pRow = exports.oxmysql:executeSync(
        'SELECT id FROM xcore_players WHERE identifier = ? LIMIT 1', { identifier }
    )
    if not pRow or not pRow[1] then return resolve({}) end

    local chars = exports.oxmysql:executeSync(
        'SELECT id, slot, firstname, lastname, dob, gender, job, job_grade, cash, bank, skin '..
        'FROM xcore_characters WHERE player_id = ? ORDER BY slot',
        { pRow[1].id }
    )
    resolve(chars or {})
end)

XCoreCallback('xc_core:createCharacter', function(source, data, resolve)
    if not data or not data.firstname or not data.lastname then
        return resolve({ success=false, error='Dati mancanti' })
    end

    local identifier = GetPlayerIdentifier(source, 0)
    local pRow = exports.oxmysql:executeSync(
        'SELECT id FROM xcore_players WHERE identifier = ? LIMIT 1', { identifier }
    )
    if not pRow or not pRow[1] then return resolve({ success=false, error='Player non trovato' }) end

    local playerId = pRow[1].id
    local slot     = data.slot or 1

    
    local existing = exports.oxmysql:executeSync(
        'SELECT id FROM xcore_characters WHERE player_id = ? AND slot = ? LIMIT 1',
        { playerId, slot }
    )
    if existing and existing[1] then
        return resolve({ success=false, error='Slot già occupato' })
    end

    local phone = XCoreUtils.GeneratePhone()
    local charId = exports.oxmysql:executeSync(
        'INSERT INTO xcore_characters (player_id, slot, firstname, lastname, dob, gender, phone, cash, bank) VALUES (?,?,?,?,?,?,?,?,?)',
        { playerId, slot, data.firstname, data.lastname, data.dob, data.gender or 0, phone, XCoreConfig.StartingCash, XCoreConfig.StartingBank }
    )

    resolve({ success=true, charId=charId, phone=phone })
end)

XCoreCallback('xc_core:deleteCharacter', function(source, data, resolve)
    if not data or not data.charId then return resolve(false) end

    local identifier = GetPlayerIdentifier(source, 0)
    local pRow = exports.oxmysql:executeSync(
        'SELECT id FROM xcore_players WHERE identifier = ? LIMIT 1', { identifier }
    )
    if not pRow or not pRow[1] then return resolve(false) end

    
    local charRow = exports.oxmysql:executeSync(
        'SELECT id FROM xcore_characters WHERE id = ? AND player_id = ? LIMIT 1',
        { data.charId, pRow[1].id }
    )
    if not charRow or not charRow[1] then return resolve(false) end

    exports.oxmysql:execute('DELETE FROM xcore_characters WHERE id = ?', { data.charId })
    resolve(true)
end)
