ESX = {}
local _loaded = false

function ESX.GetPlayerData()
    local data = exports['xc_core']:GetPlayerData()
    if not data then return {} end
    return {
        identifier = data.identifier,
        name       = data.name and data.name.full or '',
        job = {
            name       = data.job and data.job.name or 'unemployed',
            label      = data.job and data.job.label or 'Disoccupato',
            grade      = data.job and data.job.grade or 0,
            grade_name = data.job and data.job.gradeLabel or '',
            grade_label= data.job and data.job.gradeLabel or '',
            salary     = data.job and data.job.salary or 0,
        },
        accounts = {
            { name='money',       money = data.money and data.money.cash or 0 },
            { name='bank',        money = data.money and data.money.bank or 0 },
            { name='black_money', money = data.money and data.money.black_money or 0 },
        },
        inventory = {},
        metadata  = data.metadata or {},
        group     = data.group or 'user',
    }
end

function ESX.TriggerServerCallback(name, cb, ...)
    local args = { ... }
    exports['xc_core']:TriggerCallback(name, args, function(result)
        cb(result)
    end)
end

function ESX.RegisterClientCallback(name, cb)
    RegisterNetEvent('esx:' .. name)
    AddEventHandler('esx:' .. name, cb)
end

function ESX.ShowNotification(msg, type)
    TriggerEvent('xc_notify:send', { type = type or 'info', msg = msg })
end

function ESX.ShowHelpNotification(msg)
    TriggerEvent('xc_notify:send', { type = 'info', msg = msg })
end

function ESX.UI.Menu(type, namespace, name, title, align, elements, cb, exiting)
    TriggerEvent('xc_menu:open', {
        title    = title,
        elements = elements,
        onSelect = cb,
        onClose  = exiting,
    })
end

function ESX.UI.Menu.CloseAll()
    TriggerEvent('xc_menu:close')
end

ESX.UI = ESX.UI or {}

AddEventHandler('xc_core:client:loaded', function(data)
    if not _loaded then
        _loaded = true
        TriggerEvent('esx:playerLoaded', ESX.GetPlayerData())
    end
end)

AddEventHandler('xc_core:client:jobChanged', function(job)
    TriggerEvent('esx:setPlayerData', 'job', {
        name  = job.name,
        label = job.label,
        grade = job.grade,
        grade_label = job.gradeLabel,
    })
end)

_ENV.ESX = ESX

exports('getSharedObject', function()
    return ESX
end)
