QBCore = {}
QBCore.Functions = {}
QBCore.Utils     = {}

function QBCore.Functions.GetPlayerData()
    local data = exports['xc_core']:GetPlayerData()
    if not data then return {} end
    return {
        source     = GetPlayerServerId(PlayerId()),
        identifier = data.identifier,
        citizenid  = data.identifier,
        name       = data.name and data.name.full or '',
        job = {
            name   = data.job and data.job.name or 'unemployed',
            label  = data.job and data.job.label or 'Disoccupato',
            grade  = { level = data.job and data.job.grade or 0, name = data.job and data.job.gradeLabel or '' },
            salary = data.job and data.job.salary or 0,
            isboss = data.job and data.job.isBoss or false,
        },
        gang = {
            name   = data.gang and data.gang.name or 'none',
            label  = data.gang and data.gang.label or 'Nessuna',
            grade  = { level = data.gang and data.gang.grade or 0 },
            isboss = data.gang and data.gang.isBoss or false,
        },
        money = {
            cash        = data.money and data.money.cash or 0,
            bank        = data.money and data.money.bank or 0,
            black_money = data.money and data.money.black_money or 0,
        },
        charinfo = {
            firstname   = data.name and data.name.first or 'Sconosciuto',
            lastname    = data.name and data.name.last  or 'Sconosciuto',
            phone       = data.phone or '',
            gender      = data.gender or 0,
            nationality = data.nationality or 'Italiana',
        },
        metadata = data.metadata or {},
        isDead   = data.isDead or false,
    }
end

function QBCore.Functions.TriggerCallback(name, cb, ...)
    local args = { ... }
    exports['xc_core']:TriggerCallback(name, args, function(result)
        cb(result)
    end)
end

function QBCore.Functions.Notify(text, type, duration)
    TriggerEvent('xc_notify:send', {
        type     = type or 'primary',
        msg      = text,
        duration = duration or 3000,
    })
end

function QBCore.Functions.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, finish, cancel)
    TriggerEvent('xc_menu:progressbar', {
        label    = label,
        duration = duration,
        onFinish = finish,
        onCancel = cancel,
    })
end

function QBCore.Utils.DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry('STRING')
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

AddEventHandler('xc_core:client:loaded', function(data)
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerData', QBCore.Functions.GetPlayerData())
end)

AddEventHandler('xc_core:client:jobChanged', function(job)
    TriggerEvent('QBCore:Client:OnJobUpdate', {
        name   = job.name,
        label  = job.label,
        grade  = { level = job.grade, name = job.gradeLabel },
        isboss = job.isBoss,
    })
end)

_ENV.QBCore = QBCore

exports('GetCoreObject', function()
    return QBCore
end)
