QBCore = {}
QBCore.Functions = {}
QBCore.Utils     = {}
QBCore.Config    = {}
QBCore.Shared    = {}

QBCore.Config.Prefix     = '/'
QBCore.Config.MaxPlayers = GetConvarInt('sv_maxclients', 64)

function QBCore.Functions.GetPlayer(source)
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return nil end
    return QBCore._WrapPlayer(player, source)
end

function QBCore.Functions.GetPlayerByCitizenId(citizenid)
    
    local player = exports['xc_core']:GetPlayerByIdentifier(citizenid)
    if not player then return nil end
    return QBCore._WrapPlayer(player, player.source)
end

function QBCore.Functions.GetPlayers()
    local sources = {}
    for src, _ in pairs(exports['xc_core']:GetPlayers()) do
        table.insert(sources, src)
    end
    return sources
end

function QBCore.Functions.GetQBPlayers()
    local players = {}
    for src, player in pairs(exports['xc_core']:GetPlayers()) do
        players[src] = QBCore._WrapPlayer(player, src)
    end
    return players
end

function QBCore.Functions.CreateCallback(name, cb)
    exports['xc_core']:RegisterCallback(name, function(source, data, resolve)
        cb(source, resolve, data)
    end)
end

function QBCore.Functions.TriggerCallback(name, source, cb, ...)
    XCoreUtils.Log('bridge', 'QBCore.Functions.TriggerCallback server-side — usa il client', 'warn')
end

function QBCore.Functions.Notify(source, text, type, duration)
    TriggerClientEvent('xc_notify:send', source, {
        type     = type or 'info',
        msg      = text,
        duration = duration or 3000,
    })
end

function QBCore.Functions.AddItem(source, item, amount)
    if exports['xc_inventory'] then
        return exports['xc_inventory']:AddItem(source, item, amount)
    end
    return false
end

function QBCore.Functions.RemoveItem(source, item, amount)
    if exports['xc_inventory'] then
        return exports['xc_inventory']:RemoveItem(source, item, amount)
    end
    return false
end

function QBCore.Functions.HasItem(source, item, amount)
    if exports['xc_inventory'] then
        return exports['xc_inventory']:HasItem(source, item, amount)
    end
    return false
end

function QBCore._WrapPlayer(player, source)
    local qPlayer = {}

    qPlayer.PlayerData = {
        source     = source,
        identifier = player.identifier,
        citizenid  = player.identifier,
        name       = player.name.full,
        group      = player.group,
        job = {
            name       = player.job.name,
            label      = player.job.label,
            grade      = { level = player.job.grade, name = player.job.gradeLabel },
            salary     = player.job.salary,
            isboss     = player.job.isBoss,
        },
        gang = {
            name   = player.gang.name,
            label  = player.gang.label,
            grade  = { level = player.gang.grade },
            isboss = player.gang.isBoss,
        },
        money = {
            cash        = player.money.cash,
            bank        = player.money.bank,
            crypto      = 0,
            black_money = player.money.black_money,
        },
        charinfo = {
            firstname   = player.name.first,
            lastname    = player.name.last,
            phone       = player.phone,
            gender      = player.gender,
            nationality = player.nationality,
        },
        metadata = player.metadata or {},
        isDead   = player.isDead,
    }

    function qPlayer.Functions.GetName()
        return player.name.full
    end

    function qPlayer.Functions.AddMoney(moneytype, amount, reason)
        exports['xc_core']:AddMoney(source, moneytype, amount, reason)
        qPlayer.PlayerData.money[moneytype] = (qPlayer.PlayerData.money[moneytype] or 0) + amount
    end

    function qPlayer.Functions.RemoveMoney(moneytype, amount, reason)
        local ok = exports['xc_core']:RemoveMoney(source, moneytype, amount, reason)
        if ok then qPlayer.PlayerData.money[moneytype] = (qPlayer.PlayerData.money[moneytype] or 0) - amount end
        return ok
    end

    function qPlayer.Functions.GetMoney(moneytype)
        return player.money[moneytype] or 0
    end

    function qPlayer.Functions.SetJob(jobName, grade)
        exports['xc_core']:SetJob(source, jobName, grade)
    end

    function qPlayer.Functions.SetGang(gangName, grade)
        exports['xc_core']:SetGang(source, gangName, grade)
    end

    function qPlayer.Functions.SetMetaData(meta, val)
        player:SetMetadata(meta, val)
        qPlayer.PlayerData.metadata[meta] = val
    end

    function qPlayer.Functions.GetMetaData(meta)
        return player:GetMetadata(meta)
    end

    function qPlayer.Functions.AddItem(item, amount)
        return QBCore.Functions.AddItem(source, item, amount)
    end

    function qPlayer.Functions.RemoveItem(item, amount)
        return QBCore.Functions.RemoveItem(source, item, amount)
    end

    function qPlayer.Functions.HasItem(item, amount)
        return QBCore.Functions.HasItem(source, item, amount)
    end

    function qPlayer.Functions.Notify(text, type, duration)
        QBCore.Functions.Notify(source, text, type, duration)
    end

    function qPlayer.Functions.Save()
        exports['xc_core']:SavePlayer(source)
    end

    qPlayer.Functions = qPlayer.Functions or {}
    return qPlayer
end

QBCore.Shared.Jobs  = exports['xc_core']:GetJobs()
QBCore.Shared.Gangs = exports['xc_core']:GetGangs()

_ENV.QBCore = QBCore

exports('GetCoreObject', function()
    return QBCore
end)

XCoreUtils.Log('bridge', 'QBCore Bridge (server) attivo')
