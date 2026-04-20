XCorePlayers = {}

XCoreJobs  = {}
XCoreGangs = {}

local function LoadJobs()
    local jobs = exports.oxmysql:executeSync(
        'SELECT j.name, j.label, j.type, j.is_whitelisted, g.grade, g.name AS gname, g.label AS glabel, g.salary, g.is_boss '..
        'FROM xcore_jobs j LEFT JOIN xcore_job_grades g ON g.job_name = j.name ORDER BY j.name, g.grade'
    )
    XCoreJobs = {}
    for _, row in ipairs(jobs) do
        if not XCoreJobs[row.name] then
            XCoreJobs[row.name] = {
                name          = row.name,
                label         = row.label,
                type          = row.type,
                isWhitelisted = row.is_whitelisted == 1,
                grades        = {},
            }
        end
        if row.grade then
            XCoreJobs[row.name].grades[row.grade] = {
                name   = row.gname,
                label  = row.glabel,
                salary = row.salary,
                isBoss = row.is_boss == 1,
            }
        end
    end
    XCoreUtils.Log('core', ('Caricati %d lavori dal DB'):format(#jobs > 0 and #jobs or 0))
end

local function LoadGangs()
    local gangs = exports.oxmysql:executeSync(
        'SELECT g.name, g.label, gr.grade, gr.name AS gname, gr.label AS glabel, gr.is_boss '..
        'FROM xcore_gangs g LEFT JOIN xcore_gang_grades gr ON gr.gang_name = g.name ORDER BY g.name, gr.grade'
    )
    XCoreGangs = {}
    for _, row in ipairs(gangs) do
        if not XCoreGangs[row.name] then
            XCoreGangs[row.name] = { name=row.name, label=row.label, grades={} }
        end
        if row.grade then
            XCoreGangs[row.name].grades[row.grade] = { name=row.gname, label=row.glabel, isBoss=row.is_boss==1 }
        end
    end
end

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    LoadJobs()
    LoadGangs()
    XCoreUtils.Log('core', 'XCore v'..XCoreConfig.Version..' avviato con successo', 'info')
end)

exports('GetPlayer', function(source)
    return XCorePlayers[tonumber(source)]
end)

exports('GetPlayers', function()
    return XCorePlayers
end)

exports('GetJob', function(jobName)
    return XCoreJobs[jobName]
end)

exports('GetJobs', function()
    return XCoreJobs
end)

exports('GetGangs', function()
    return XCoreGangs
end)

exports('ReloadJobs', function()
    LoadJobs()
    LoadGangs()
end)

exports('GetPlayerByIdentifier', function(identifier)
    for _, player in pairs(XCorePlayers) do
        if player.identifier == identifier then return player end
    end
    return nil
end)
