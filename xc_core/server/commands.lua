local function IsAdmin(source)
    local player = XCorePlayers[source]
    return player and player:IsAdmin()
end

RegisterCommand('setjob', function(source, args)
    if not IsAdmin(source) then
        TriggerClientEvent('xc_notify:send', source, { type='error', msg='Permesso negato.' })
        return
    end
    local target = tonumber(args[1])
    local job    = args[2]
    local grade  = tonumber(args[3]) or 0
    if not target or not job then
        TriggerClientEvent('xc_notify:send', source, { type='error', msg='Uso: /setjob [id] [job] [grade]' })
        return
    end
    if SetJob(target, job, grade) then
        TriggerClientEvent('xc_notify:send', source, { type='success', msg=('Lavoro impostato: %s g%d'):format(job, grade) })
    else
        TriggerClientEvent('xc_notify:send', source, { type='error', msg='Job non trovato o player non connesso.' })
    end
end, false)

RegisterCommand('givemoney', function(source, args)
    if not IsAdmin(source) then
        TriggerClientEvent('xc_notify:send', source, { type='error', msg='Permesso negato.' })
        return
    end
    local target  = tonumber(args[1])
    local account = args[2] or 'cash'
    local amount  = tonumber(args[3])
    if not target or not amount then
        TriggerClientEvent('xc_notify:send', source, { type='error', msg='Uso: /givemoney [id] [account] [amount]' })
        return
    end
    if AddMoney(target, account, amount, 'Admin give') then
        TriggerClientEvent('xc_notify:send', source, { type='success', msg=('Dati %s %s a %d'):format(XCoreUtils.FormatMoney(amount), account, target) })
    else
        TriggerClientEvent('xc_notify:send', source, { type='error', msg='Errore.' })
    end
end, false)

RegisterCommand('removemoney', function(source, args)
    if not IsAdmin(source) then return end
    local target  = tonumber(args[1])
    local account = args[2] or 'cash'
    local amount  = tonumber(args[3])
    if not target or not amount then return end
    RemoveMoney(target, account, amount, 'Admin remove')
end, false)

RegisterCommand('kick', function(source, args)
    if not IsAdmin(source) then return end
    local target = tonumber(args[1])
    if not target then return end
    local reason = table.concat(args, ' ', 2) or 'Nessun motivo'
    DropPlayer(target, '[XCore] Sei stato kickato: ' .. reason)
    TriggerClientEvent('xc_notify:send', source, { type='success', msg=('Player %d kickato.'):format(target) })
end, false)

RegisterCommand('ban', function(source, args)
    if not IsAdmin(source) then return end
    local target = tonumber(args[1])
    local days   = tonumber(args[2])
    if not target then return end
    local reason = table.concat(args, ' ', days and 3 or 2) or 'Nessun motivo'
    local identifier = GetPlayerIdentifier(target, 0)
    local name       = GetPlayerName(target)
    local expiresAt  = nil
    if days and days > 0 then
        expiresAt = os.date('%Y-%m-%d %H:%M:%S', os.time() + days * 86400)
    end
    exports.oxmysql:execute(
        'INSERT INTO xcore_bans (identifier, name, reason, banned_by, expires_at) VALUES (?,?,?,?,?)',
        { identifier, name, reason, GetPlayerName(source), expiresAt }
    )
    exports.oxmysql:execute('UPDATE xcore_players SET banned=1 WHERE identifier=?', { identifier })
    DropPlayer(target, '[XCore] Sei stato bannato: ' .. reason)
    TriggerClientEvent('xc_notify:send', source, { type='success', msg=('Player %s bannato.'):format(name) })
end, false)

RegisterCommand('unban', function(source, args)
    if not IsAdmin(source) then return end
    local identifier = args[1]
    if not identifier then return end
    exports.oxmysql:execute('DELETE FROM xcore_bans WHERE identifier=?', { identifier })
    exports.oxmysql:execute('UPDATE xcore_players SET banned=0 WHERE identifier=?', { identifier })
    TriggerClientEvent('xc_notify:send', source, { type='success', msg='Player sbannato.' })
end, false)

RegisterCommand('players', function(source, args)
    if not IsAdmin(source) then return end
    local list = {}
    for src, player in pairs(XCorePlayers) do
        table.insert(list, ('[%d] %s — %s'):format(src, player.name.full, player.job.name))
    end
    if #list == 0 then
        TriggerClientEvent('xc_notify:send', source, { type='info', msg='Nessun player connesso.' })
    else
        for _, line in ipairs(list) do
            TriggerClientEvent('xc_notify:send', source, { type='info', msg=line })
        end
    end
end, false)

RegisterCommand('revive', function(source, args)
    if not IsAdmin(source) then return end
    local target = tonumber(args[1]) or source
    TriggerClientEvent('xc_core:client:revive', target)
    TriggerEvent('xc_core:server:playerRevived', target)
end, false)
