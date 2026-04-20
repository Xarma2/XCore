exports['xc_core']:RegisterCallback('xc_jobs:getEmployees', function(source, data, resolve)
    local player = exports['xc_core']:GetPlayer(source)
    if not player or not player.job.isBoss then
        return resolve({ success=false, error='Non sei il boss' })
    end

    local rows = exports.oxmysql:executeSync(
        'SELECT c.id, c.firstname, c.lastname, c.job_grade, jg.label AS grade_label '..
        'FROM xcore_characters c '..
        'LEFT JOIN xcore_job_grades jg ON jg.job_name = c.job AND jg.grade = c.job_grade '..
        'WHERE c.job = ? ORDER BY c.job_grade DESC, c.lastname',
        { player.job.name }
    )
    resolve({ success=true, employees=rows or {} })
end)

exports['xc_core']:RegisterCallback('xc_jobs:setEmployeeGrade', function(source, data, resolve)
    local player = exports['xc_core']:GetPlayer(source)
    if not player or not player.job.isBoss then
        return resolve({ success=false, error='Non sei il boss' })
    end
    if not data or not data.charId or data.grade == nil then
        return resolve({ success=false, error='Dati mancanti' })
    end

    
    local charRow = exports.oxmysql:executeSync(
        'SELECT id, job FROM xcore_characters WHERE id = ? LIMIT 1', { data.charId }
    )
    if not charRow or not charRow[1] or charRow[1].job ~= player.job.name then
        return resolve({ success=false, error='Dipendente non trovato' })
    end

    
    exports.oxmysql:execute(
        'UPDATE xcore_characters SET job_grade = ? WHERE id = ?', { data.grade, data.charId }
    )

    
    for src, p in pairs(exports['xc_core']:GetPlayers()) do
        if p.charId == data.charId then
            exports['xc_core']:SetJob(src, player.job.name, data.grade)
            break
        end
    end

    resolve({ success=true })
end)

exports['xc_core']:RegisterCallback('xc_jobs:fireEmployee', function(source, data, resolve)
    local player = exports['xc_core']:GetPlayer(source)
    if not player or not player.job.isBoss then
        return resolve({ success=false, error='Non sei il boss' })
    end
    if not data or not data.charId then
        return resolve({ success=false, error='Dati mancanti' })
    end

    
    if data.charId == player.charId then
        return resolve({ success=false, error='Non puoi licenziare te stesso' })
    end

    exports.oxmysql:execute(
        'UPDATE xcore_characters SET job=?, job_grade=0 WHERE id=?', { 'unemployed', data.charId }
    )

    
    for src, p in pairs(exports['xc_core']:GetPlayers()) do
        if p.charId == data.charId then
            exports['xc_core']:SetJob(src, 'unemployed', 0)
            TriggerClientEvent('xc_notify:send', src, {
                type='error', msg='Sei stato licenziato.'
            })
            break
        end
    end

    resolve({ success=true })
end)

exports['xc_core']:RegisterCallback('xc_jobs:hireEmployee', function(source, data, resolve)
    local player = exports['xc_core']:GetPlayer(source)
    if not player or not player.job.isBoss then
        return resolve({ success=false, error='Non sei il boss' })
    end
    if not data or not data.charId then
        return resolve({ success=false, error='Dati mancanti' })
    end

    exports.oxmysql:execute(
        'UPDATE xcore_characters SET job=?, job_grade=0 WHERE id=?', { player.job.name, data.charId }
    )

    for src, p in pairs(exports['xc_core']:GetPlayers()) do
        if p.charId == data.charId then
            exports['xc_core']:SetJob(src, player.job.name, 0)
            TriggerClientEvent('xc_notify:send', src, {
                type='success', msg=('Sei stato assunto come %s!'):format(player.job.label)
            })
            break
        end
    end

    resolve({ success=true })
end)

RegisterNetEvent('xc_jobs:server:setDuty', function(state)
    local source = source
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return end
    Player(source).state:set('xcore:onDuty', state, true)
    TriggerEvent('xc_jobs:dutyChanged', source, player, state)
    XCoreUtils.Log('jobs', ('%s — duty: %s'):format(player.name.full, tostring(state)))
end)

XCoreUtils.Log('jobs', 'Jobs module avviato')
