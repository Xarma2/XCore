RegisterNetEvent('xc_multichar:server:selectCharacter', function(slot)
    local source = source
    
    TriggerEvent('xc_core:server:playerLoaded', source, slot)
    
    TriggerNetEvent('xc_core:server:playerLoaded', source)
    
    local identifier = GetPlayerIdentifier(source, 0)
    if not identifier then
        DropPlayer(source, '[XCore] Identificatore non valido.')
        return
    end

    local pRow = exports.oxmysql:executeSync(
        'SELECT id, `group`, banned FROM xcore_players WHERE identifier = ? LIMIT 1',
        { identifier }
    )
    if not pRow or not pRow[1] then
        DropPlayer(source, '[XCore] Profilo non trovato.')
        return
    end

    local playerId = pRow[1].id
    local group    = pRow[1].group

    if pRow[1].banned == 1 then
        DropPlayer(source, '[XCore] Sei bannato.')
        return
    end

    local charRows = exports.oxmysql:executeSync(
        'SELECT c.*, j.label AS job_label, jg.label AS job_grade_label, jg.salary AS job_salary, jg.is_boss AS job_is_boss, '..
        'g.label AS gang_label, gg.is_boss AS gang_is_boss '..
        'FROM xcore_characters c '..
        'LEFT JOIN xcore_jobs j ON j.name = c.job '..
        'LEFT JOIN xcore_job_grades jg ON jg.job_name = c.job AND jg.grade = c.job_grade '..
        'LEFT JOIN xcore_gangs g ON g.name = c.gang '..
        'LEFT JOIN xcore_gang_grades gg ON gg.gang_name = c.gang AND gg.grade = c.gang_grade '..
        'WHERE c.player_id = ? AND c.slot = ? LIMIT 1',
        { playerId, slot or 1 }
    )

    local charData
    if charRows and charRows[1] then
        charData = charRows[1]
    else
        local phone = XCoreUtils.GeneratePhone()
        local newId = exports.oxmysql:executeSync(
            'INSERT INTO xcore_characters (player_id, slot, phone, cash, bank) VALUES (?,?,?,?,?)',
            { playerId, slot or 1, phone, XCoreConfig.StartingCash, XCoreConfig.StartingBank }
        )
        charData = {
            id=newId, player_id=playerId, slot=slot or 1,
            firstname='Sconosciuto', lastname='Sconosciuto',
            job='unemployed', job_grade=0, job_label='Disoccupato',
            job_grade_label='Disoccupato', job_salary=0, job_is_boss=0,
            gang='none', gang_grade=0, gang_label='Nessuna', gang_is_boss=0,
            cash=XCoreConfig.StartingCash, bank=XCoreConfig.StartingBank, black_money=0,
            position=nil, metadata=nil, status=nil, skin=nil, is_dead=0, phone=phone,
        }
    end

    charData.identifier = identifier
    charData.char_id    = charData.id
    charData.group      = group

    local player = XCorePlayer.New(charData, source)
    XCorePlayers[source] = player

    local state = Player(source).state
    state:set('xcore:loaded',    true,             true)
    state:set('xcore:charId',    player.charId,    true)
    state:set('xcore:name',      player.name.full, true)
    state:set('xcore:job',       player.job.name,  true)
    state:set('xcore:jobGrade',  player.job.grade, true)
    state:set('xcore:gang',      player.gang.name, true)
    state:set('xcore:isDead',    player.isDead,    true)
    state:set('xcore:group',     player.group,     true)

    TriggerClientEvent('xc_core:client:playerLoaded', source, {
        charId   = player.charId,
        name     = player.name,
        job      = player.job,
        job2     = player.job2,
        gang     = player.gang,
        money    = player.money,
        position = player.position,
        metadata = player.metadata,
        status   = player.status,
        skin     = player.skin,
        isDead   = player.isDead,
        group    = player.group,
        phone    = player.phone,
    })

    TriggerEvent('xc_core:playerLoaded', source, player)
    TriggerClientEvent('xc_multichar:close', source)
end)
