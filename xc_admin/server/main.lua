local function HasPermission(source, level)
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return false end
    local groups = { superadmin=5, admin=4, moderator=3, helper=2, vip=1, user=0 }
    local required = groups[level] or 0
    local playerLevel = groups[player.group] or 0
    return playerLevel >= required
end

exports('HasPermission', HasPermission)

exports['xc_core']:RegisterCallback('xc_admin:getPlayers', function(source, data, resolve)
    if not HasPermission(source, 'helper') then return resolve(nil) end
    local players = {}
    for _, pid in ipairs(GetPlayers()) do
        local player = exports['xc_core']:GetPlayer(tonumber(pid))
        if player then
            table.insert(players, {
                source   = pid,
                charId   = player.charId,
                name     = player.name.full,
                job      = player.job.label,
                group    = player.group,
                ping     = GetPlayerPing(pid),
                identifiers = {
                    steam   = GetPlayerIdentifierByType(pid, 'steam'),
                    license = GetPlayerIdentifierByType(pid, 'license'),
                    discord = GetPlayerIdentifierByType(pid, 'discord'),
                }
            })
        end
    end
    resolve(players)
end)

RegisterCommand('kick', function(source, args)
    if not HasPermission(source, 'moderator') then
        TriggerClientEvent('xc_notify:send', source, { type='error', msg='Non hai i permessi.' })
        return
    end
    local target = tonumber(args[1])
    local reason = table.concat(args, ' ', 2) or 'Nessun motivo'
    if not target then return end
    DropPlayer(target, '[XCore] Sei stato kickato: ' .. reason)
    TriggerClientEvent('xc_notify:send', source, { type='success', msg='Player kickato.' })
    XCoreUtils.Log('admin', ('Kick: %s → %s | Motivo: %s'):format(GetPlayerName(source), GetPlayerName(target), reason))
end, true)

RegisterCommand('setgroup', function(source, args)
    if not HasPermission(source, 'superadmin') then
        TriggerClientEvent('xc_notify:send', source, { type='error', msg='Non hai i permessi.' })
        return
    end
    local target = tonumber(args[1])
    local group  = args[2]
    if not target or not group then return end
    local player = exports['xc_core']:GetPlayer(target)
    if not player then return end
    exports.oxmysql:execute('UPDATE xcore_players SET `group` = ? WHERE identifier = ?', { group, player.identifier })
    player.group = group
    Player(target).state:set('xcore:group', group, true)
    TriggerClientEvent('xc_notify:send', source, { type='success', msg=('Gruppo aggiornato: %s → %s'):format(player.name.full, group) })
    TriggerClientEvent('xc_notify:send', target, { type='info', msg=('Il tuo gruppo è stato aggiornato a: %s'):format(group) })
end, true)

RegisterCommand('setjob', function(source, args)
    if not HasPermission(source, 'admin') then
        TriggerClientEvent('xc_notify:send', source, { type='error', msg='Non hai i permessi.' })
        return
    end
    local target = tonumber(args[1])
    local job    = args[2]
    local grade  = tonumber(args[3]) or 0
    if not target or not job then return end
    local player = exports['xc_core']:GetPlayer(target)
    if not player then return end
    player:SetJob(job, grade)
    TriggerClientEvent('xc_notify:send', source, { type='success', msg='Lavoro aggiornato.' })
end, true)

RegisterCommand('givemoney', function(source, args)
    if not HasPermission(source, 'admin') then
        TriggerClientEvent('xc_notify:send', source, { type='error', msg='Non hai i permessi.' })
        return
    end
    local target  = tonumber(args[1])
    local moneyType = args[2] or 'cash'
    local amount  = tonumber(args[3]) or 0
    if not target then return end
    exports['xc_economy']:AddMoney(target, moneyType, amount)
    TriggerClientEvent('xc_notify:send', source, { type='success', msg=('Dato €%d (%s) al player.'):format(amount, moneyType) })
end, true)

RegisterCommand('tp', function(source, args)
    if not HasPermission(source, 'moderator') then return end
    local target = tonumber(args[1])
    if target then
        TriggerClientEvent('xc_admin:tpToPlayer', source, target)
    else
        local x = tonumber(args[1])
        local y = tonumber(args[2])
        local z = tonumber(args[3])
        if x and y and z then
            TriggerClientEvent('xc_admin:tpToCoords', source, x, y, z)
        end
    end
end, true)

RegisterCommand('spectate', function(source, args)
    if not HasPermission(source, 'moderator') then return end
    local target = tonumber(args[1])
    TriggerClientEvent('xc_admin:spectate', source, target)
end, true)

RegisterCommand('noclip', function(source, args)
    if not HasPermission(source, 'moderator') then return end
    TriggerClientEvent('xc_admin:toggleNoclip', source)
end, true)

RegisterCommand('freeze', function(source, args)
    if not HasPermission(source, 'moderator') then return end
    local target = tonumber(args[1])
    if not target then return end
    TriggerClientEvent('xc_admin:freeze', target, true)
    TriggerClientEvent('xc_notify:send', source, { type='success', msg='Player freezato.' })
end, true)

RegisterCommand('unfreeze', function(source, args)
    if not HasPermission(source, 'moderator') then return end
    local target = tonumber(args[1])
    if not target then return end
    TriggerClientEvent('xc_admin:freeze', target, false)
    TriggerClientEvent('xc_notify:send', source, { type='success', msg='Player scongelato.' })
end, true)

RegisterCommand('heal', function(source, args)
    if not HasPermission(source, 'moderator') then return end
    local target = tonumber(args[1]) or source
    TriggerClientEvent('xc_admin:heal', target)
end, true)

RegisterCommand('revive', function(source, args)
    if not HasPermission(source, 'moderator') then return end
    local target = tonumber(args[1]) or source
    TriggerClientEvent('xc_admin:revive', target)
end, true)

XCoreUtils.Log('admin', 'Admin module avviato')
