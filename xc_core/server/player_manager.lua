local function GetIdentifier(source)
    local idType = XCoreConfig.Identifier
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if id and id:find(idType .. ':') then
            return id
        end
    end
    
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if id and id:find('license:') then return id end
    end
    return nil
end

local function GetAllIdentifiers(source)
    local ids = {}
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if id then
            if id:find('license:')  then ids.license  = id end
            if id:find('license2:') then ids.license2 = id end
            if id:find('steam:')    then ids.steam     = id end
            if id:find('discord:')  then ids.discord   = id end
            if id:find('ip:')       then ids.ip        = id end
        end
    end
    return ids
end

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    deferrals.defer()
    Citizen.Wait(0)

    local identifier = GetIdentifier(source)
    if not identifier then
        deferrals.done('Impossibile ottenere il tuo identificatore. Riprova.')
        return
    end

    
    local ban = exports.oxmysql:executeSync(
        'SELECT reason, expires_at FROM xcore_bans WHERE identifier = ? AND (expires_at IS NULL OR expires_at > NOW()) LIMIT 1',
        { identifier }
    )
    if ban and ban[1] then
        local reason = ban[1].reason
        local until_ = ban[1].expires_at and (' (scade: '..ban[1].expires_at..')') or ' (permanente)'
        deferrals.done('Sei bannato dal server.\nMotivo: ' .. reason .. until_)
        return
    end

    deferrals.done()
end)

RegisterNetEvent('xc_core:server:playerLoaded', function(charSlot)
    local source     = source
    local identifier = GetIdentifier(source)
    if not identifier then
        DropPlayer(source, '[XCore] Identificatore non valido.')
        return
    end

    local ids = GetAllIdentifiers(source)

    
    exports.oxmysql:executeSync(
        'INSERT INTO xcore_players (identifier, license, discord, steam, ip) VALUES (?,?,?,?,?) '..
        'ON DUPLICATE KEY UPDATE license=VALUES(license), discord=VALUES(discord), steam=VALUES(steam), ip=VALUES(ip), last_seen=NOW()',
        { identifier, ids.license, ids.discord, ids.steam, ids.ip }
    )

    
    local pRow = exports.oxmysql:executeSync(
        'SELECT id, `group`, banned FROM xcore_players WHERE identifier = ? LIMIT 1',
        { identifier }
    )
    if not pRow or not pRow[1] then
        DropPlayer(source, '[XCore] Errore nel caricamento del profilo.')
        return
    end

    local playerId = pRow[1].id
    local group    = pRow[1].group

    if pRow[1].banned == 1 then
        DropPlayer(source, '[XCore] Sei bannato da questo server.')
        return
    end

    
    local slot = charSlot or 1
    local charRows = exports.oxmysql:executeSync(
        'SELECT c.*, j.label AS job_label, jg.label AS job_grade_label, jg.salary AS job_salary, jg.is_boss AS job_is_boss, '..
        'g.label AS gang_label, gg.is_boss AS gang_is_boss '..
        'FROM xcore_characters c '..
        'LEFT JOIN xcore_jobs j ON j.name = c.job '..
        'LEFT JOIN xcore_job_grades jg ON jg.job_name = c.job AND jg.grade = c.job_grade '..
        'LEFT JOIN xcore_gangs g ON g.name = c.gang '..
        'LEFT JOIN xcore_gang_grades gg ON gg.gang_name = c.gang AND gg.grade = c.gang_grade '..
        'WHERE c.player_id = ? AND c.slot = ? LIMIT 1',
        { playerId, slot }
    )

    local charData
    if charRows and charRows[1] then
        charData = charRows[1]
    else
        
        local newCharId = exports.oxmysql:executeSync(
            'INSERT INTO xcore_characters (player_id, slot, cash, bank) VALUES (?,?,?,?)',
            { playerId, slot, XCoreConfig.StartingCash, XCoreConfig.StartingBank }
        )
        charData = {
            id = newCharId, player_id = playerId, slot = slot,
            firstname='Sconosciuto', lastname='Sconosciuto',
            job='unemployed', job_grade=0, job_label='Disoccupato',
            job_grade_label='Disoccupato', job_salary=0, job_is_boss=0,
            gang='none', gang_grade=0, gang_label='Nessuna', gang_is_boss=0,
            cash=XCoreConfig.StartingCash, bank=XCoreConfig.StartingBank, black_money=0,
            position=nil, metadata=nil, status=nil, skin=nil, is_dead=0,
        }
    end

    charData.identifier = identifier
    charData.char_id    = charData.id
    charData.group      = group

    
    local player = XCorePlayer.New(charData, source)
    XCorePlayers[source] = player

    
    local state = Player(source).state
    state:set('xcore:loaded',    true,                    true)
    state:set('xcore:charId',    player.charId,           true)
    state:set('xcore:name',      player.name.full,        true)
    state:set('xcore:job',       player.job.name,         true)
    state:set('xcore:jobGrade',  player.job.grade,        true)
    state:set('xcore:gang',      player.gang.name,        true)
    state:set('xcore:gangGrade', player.gang.grade,       true)
    state:set('xcore:isDead',    player.isDead,           true)
    state:set('xcore:group',     player.group,            true)

    
    TriggerClientEvent('xc_core:client:playerLoaded', source, {
        charId      = player.charId,
        name        = player.name,
        job         = player.job,
        job2        = player.job2,
        gang        = player.gang,
        money       = player.money,
        position    = player.position,
        metadata    = player.metadata,
        status      = player.status,
        skin        = player.skin,
        isDead      = player.isDead,
        group       = player.group,
        phone       = player.phone,
    })

    TriggerEvent('xc_core:playerLoaded', source, player)
    XCoreUtils.Log('core', ('Player caricato: %s (src:%d, charId:%d)'):format(player.name.full, source, player.charId))
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    local player = XCorePlayers[source]
    if not player then return end

    
    local ped = GetPlayerPed(source)
    if ped and ped ~= 0 then
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        player.position = { x=coords.x, y=coords.y, z=coords.z, heading=heading }
    end

    SavePlayer(source)
    TriggerEvent('xc_core:playerDropped', source, player, reason)
    XCorePlayers[source] = nil
    XCoreUtils.Log('core', ('Player disconnesso: %s (src:%d) — %s'):format(player.name.full, source, reason))
end)

function SavePlayer(source)
    local player = XCorePlayers[source]
    if not player then return end

    exports.oxmysql:execute(
        'UPDATE xcore_characters SET '..
        'job=?, job_grade=?, job2=?, job2_grade=?, gang=?, gang_grade=?, '..
        'cash=?, bank=?, black_money=?, position=?, metadata=?, status=?, skin=?, is_dead=? '..
        'WHERE id=?',
        {
            player.job.name,  player.job.grade,
            player.job2.name, player.job2.grade,
            player.gang.name, player.gang.grade,
            player.money.cash, player.money.bank, player.money.black_money,
            json.encode(player.position),
            json.encode(player.metadata),
            json.encode(player.status),
            json.encode(player.skin),
            player.isDead and 1 or 0,
            player.charId,
        }
    )
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5 * 60 * 1000)
        local count = 0
        for src, _ in pairs(XCorePlayers) do
            SavePlayer(src)
            count = count + 1
        end
        if count > 0 then
            XCoreUtils.Log('core', ('Autosave: salvati %d player'):format(count))
        end
    end
end)

function AddMoney(source, account, amount, note)
    local player = XCorePlayers[source]
    if not player or amount <= 0 then return false end
    player.money[account] = (player.money[account] or 0) + amount
    TriggerClientEvent('xc_core:client:moneyUpdated', source, player.money)
    Player(source).state:set('xcore:cash', player.money.cash, true)
    exports.oxmysql:execute(
        'INSERT INTO xcore_transactions (char_id, type, amount, account, note) VALUES (?,?,?,?,?)',
        { player.charId, 'add', amount, account, note or '' }
    )
    return true
end

function RemoveMoney(source, account, amount, note)
    local player = XCorePlayers[source]
    if not player or amount <= 0 then return false end
    if (player.money[account] or 0) < amount then return false end
    player.money[account] = player.money[account] - amount
    TriggerClientEvent('xc_core:client:moneyUpdated', source, player.money)
    Player(source).state:set('xcore:cash', player.money.cash, true)
    exports.oxmysql:execute(
        'INSERT INTO xcore_transactions (char_id, type, amount, account, note) VALUES (?,?,?,?,?)',
        { player.charId, 'remove', amount, account, note or '' }
    )
    return true
end

function SetMoney(source, account, amount)
    local player = XCorePlayers[source]
    if not player or amount < 0 then return false end
    player.money[account] = amount
    TriggerClientEvent('xc_core:client:moneyUpdated', source, player.money)
    return true
end

function SetJob(source, jobName, grade)
    local player = XCorePlayers[source]
    if not player then return false end
    local job = XCoreJobs[jobName]
    if not job then return false end
    grade = grade or 0
    local gradeData = job.grades[grade] or job.grades[0] or {}
    player.job = {
        name       = jobName,
        grade      = grade,
        label      = job.label,
        gradeLabel = gradeData.label or '',
        salary     = gradeData.salary or 0,
        isBoss     = gradeData.isBoss or false,
    }
    Player(source).state:set('xcore:job',      player.job.name,  true)
    Player(source).state:set('xcore:jobGrade', player.job.grade, true)
    TriggerClientEvent('xc_core:client:jobUpdated', source, player.job)
    TriggerEvent('xc_core:jobUpdated', source, player.job)
    return true
end

function SetGang(source, gangName, grade)
    local player = XCorePlayers[source]
    if not player then return false end
    local gang = XCoreGangs[gangName]
    if not gang then return false end
    grade = grade or 0
    local gradeData = gang.grades[grade] or gang.grades[0] or {}
    player.gang = {
        name   = gangName,
        grade  = grade,
        label  = gang.label,
        isBoss = gradeData.isBoss or false,
    }
    Player(source).state:set('xcore:gang',      player.gang.name,  true)
    Player(source).state:set('xcore:gangGrade', player.gang.grade, true)
    TriggerClientEvent('xc_core:client:gangUpdated', source, player.gang)
    return true
end

exports('AddMoney',    AddMoney)
exports('RemoveMoney', RemoveMoney)
exports('SetMoney',    SetMoney)
exports('SetJob',      SetJob)
exports('SetGang',     SetGang)
exports('SavePlayer',  SavePlayer)
