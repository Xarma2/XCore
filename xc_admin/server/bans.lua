local function HasPermission(source, level)
    return exports['xc_admin']:HasPermission(source, level)
end

local function BanPlayer(source, target, reason, duration)
    local player = exports['xc_core']:GetPlayer(target)
    if not player then return false end

    local expireAt = nil
    if duration and duration > 0 then
        expireAt = os.time() + (duration * 3600)
    end

    
    exports.oxmysql:execute(
        'UPDATE xcore_players SET banned=1, ban_reason=?, ban_expire=? WHERE identifier=?',
        { reason, expireAt, player.identifier }
    )

    
    exports.oxmysql:execute(
        'INSERT INTO xcore_bans (identifier, reason, admin_id, expire_at) VALUES (?,?,?,?)',
        { player.identifier, reason, GetPlayerIdentifier(source, 0), expireAt }
    )

    local durationStr = duration and duration > 0 and ('%d ore'):format(duration) or 'Permanente'
    DropPlayer(target, ('[XCore] Sei stato bannato.\nMotivo: %s\nDurata: %s'):format(reason, durationStr))

    TriggerClientEvent('xc_notify:send', source, {
        type='success',
        msg=('Player bannato: %s | %s'):format(player.name.full, durationStr)
    })

    XCoreUtils.Log('admin', ('BAN: %s → %s | Motivo: %s | Durata: %s'):format(
        GetPlayerName(source), player.name.full, reason, durationStr
    ))
    return true
end

local function UnbanPlayer(identifier)
    exports.oxmysql:execute(
        'UPDATE xcore_players SET banned=0, ban_reason=NULL, ban_expire=NULL WHERE identifier=?',
        { identifier }
    )
    XCoreUtils.Log('admin', ('UNBAN: %s'):format(identifier))
end

local function CheckExpiredBans()
    exports.oxmysql:execute(
        'UPDATE xcore_players SET banned=0, ban_reason=NULL, ban_expire=NULL WHERE banned=1 AND ban_expire IS NOT NULL AND ban_expire <= ?',
        { os.time() }
    )
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000)
        CheckExpiredBans()
    end
end)

RegisterCommand('ban', function(source, args)
    if not HasPermission(source, 'moderator') then
        TriggerClientEvent('xc_notify:send', source, { type='error', msg='Non hai i permessi.' })
        return
    end
    local target   = tonumber(args[1])
    local duration = tonumber(args[2]) or 0
    local reason   = table.concat(args, ' ', 3) or 'Nessun motivo'
    if not target then
        TriggerClientEvent('xc_notify:send', source, { type='error', msg='Uso: /ban [id] [ore] [motivo]' })
        return
    end
    BanPlayer(source, target, reason, duration)
end, true)

RegisterCommand('unban', function(source, args)
    if not HasPermission(source, 'admin') then
        TriggerClientEvent('xc_notify:send', source, { type='error', msg='Non hai i permessi.' })
        return
    end
    local identifier = args[1]
    if not identifier then
        TriggerClientEvent('xc_notify:send', source, { type='error', msg='Uso: /unban [identifier]' })
        return
    end
    UnbanPlayer(identifier)
    TriggerClientEvent('xc_notify:send', source, { type='success', msg='Ban rimosso.' })
end, true)

exports['xc_core']:RegisterCallback('xc_admin:getBans', function(source, data, resolve)
    if not HasPermission(source, 'admin') then return resolve(nil) end
    local bans = exports.oxmysql:executeSync(
        'SELECT p.identifier, p.ban_reason, p.ban_expire FROM xcore_players p WHERE p.banned=1 ORDER BY p.id DESC LIMIT 50'
    )
    resolve(bans or {})
end)

exports('BanPlayer', BanPlayer)
exports('UnbanPlayer', UnbanPlayer)
