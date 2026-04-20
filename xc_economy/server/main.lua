exports('BankTransfer', function(fromSource, toCharId, amount, note)
    if amount <= 0 then return false, 'Importo non valido' end

    local fromPlayer = exports['xc_core']:GetPlayer(fromSource)
    if not fromPlayer then return false, 'Player non trovato' end
    if fromPlayer.money.bank < amount then return false, 'Saldo insufficiente' end

    
    local toRow = exports.oxmysql:executeSync(
        'SELECT id, bank FROM xcore_characters WHERE id = ? LIMIT 1', { toCharId }
    )
    if not toRow or not toRow[1] then return false, 'Destinatario non trovato' end

    
    exports['xc_core']:RemoveMoney(fromSource, 'bank', amount, note or 'Bonifico')

    
    local toOnline = nil
    for src, p in pairs(exports['xc_core']:GetPlayers()) do
        if p.charId == toCharId then toOnline = src break end
    end

    if toOnline then
        exports['xc_core']:AddMoney(toOnline, 'bank', amount, note or 'Bonifico ricevuto')
    else
        exports.oxmysql:execute(
            'UPDATE xcore_characters SET bank = bank + ? WHERE id = ?', { amount, toCharId }
        )
    end

    
    exports.oxmysql:execute(
        'INSERT INTO xcore_transactions (char_id, type, amount, account, note) VALUES (?,?,?,?,?)',
        { fromPlayer.charId, 'transfer_out', amount, 'bank', ('Bonifico a charId %d'):format(toCharId) }
    )
    exports.oxmysql:execute(
        'INSERT INTO xcore_transactions (char_id, type, amount, account, note) VALUES (?,?,?,?,?)',
        { toCharId, 'transfer_in', amount, 'bank', ('Bonifico da charId %d'):format(fromPlayer.charId) }
    )

    return true, 'Bonifico effettuato'
end)

exports('Deposit', function(source, amount)
    if amount <= 0 then return false end
    local player = exports['xc_core']:GetPlayer(source)
    if not player or player.money.cash < amount then return false end
    exports['xc_core']:RemoveMoney(source, 'cash', amount, 'Deposito')
    exports['xc_core']:AddMoney(source, 'bank', amount, 'Deposito')
    return true
end)

exports('Withdraw', function(source, amount)
    if amount <= 0 then return false end
    local player = exports['xc_core']:GetPlayer(source)
    if not player or player.money.bank < amount then return false end
    exports['xc_core']:RemoveMoney(source, 'bank', amount, 'Prelievo')
    exports['xc_core']:AddMoney(source, 'cash', amount, 'Prelievo')
    return true
end)

exports('GetTransactions', function(charId, limit)
    limit = limit or 20
    return exports.oxmysql:executeSync(
        'SELECT type, amount, account, note, created_at FROM xcore_transactions WHERE char_id = ? ORDER BY created_at DESC LIMIT ?',
        { charId, limit }
    ) or {}
end)

exports['xc_core']:RegisterCallback('xc_economy:getBalance', function(source, data, resolve)
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return resolve(nil) end
    resolve({ cash = player.money.cash, bank = player.money.bank })
end)

exports['xc_core']:RegisterCallback('xc_economy:deposit', function(source, data, resolve)
    if not data or not data.amount then return resolve({ success=false, error='Importo mancante' }) end
    local ok = exports['xc_economy']:Deposit(source, data.amount)
    resolve({ success=ok, error=ok and nil or 'Saldo insufficiente' })
end)

exports['xc_core']:RegisterCallback('xc_economy:withdraw', function(source, data, resolve)
    if not data or not data.amount then return resolve({ success=false, error='Importo mancante' }) end
    local ok = exports['xc_economy']:Withdraw(source, data.amount)
    resolve({ success=ok, error=ok and nil or 'Saldo insufficiente' })
end)

exports['xc_core']:RegisterCallback('xc_economy:transfer', function(source, data, resolve)
    if not data or not data.toCharId or not data.amount then
        return resolve({ success=false, error='Dati mancanti' })
    end
    local ok, msg = exports['xc_economy']:BankTransfer(source, data.toCharId, data.amount, data.note)
    resolve({ success=ok, error=not ok and msg or nil })
end)

exports['xc_core']:RegisterCallback('xc_economy:getTransactions', function(source, data, resolve)
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return resolve({}) end
    resolve(exports['xc_economy']:GetTransactions(player.charId, 20))
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(XCoreConfig.PaycheckInterval)
        for src, player in pairs(exports['xc_core']:GetPlayers()) do
            local salary = player.job.salary or 0
            if salary > 0 then
                exports['xc_core']:AddMoney(src, 'bank', salary, 'Stipendio — ' .. player.job.label)
                TriggerClientEvent('xc_notify:send', src, {
                    type = 'success',
                    msg  = ('Hai ricevuto il tuo stipendio: %s'):format(XCoreUtils.FormatMoney(salary)),
                    duration = 5000,
                })
            end
        end
    end
end)

XCoreUtils.Log('economy', 'Economy module avviato')
