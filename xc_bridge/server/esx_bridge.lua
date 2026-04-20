ESX = {}

function ESX.GetPlayerFromId(source)
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return nil end
    return ESX._WrapPlayer(player, source)
end

function ESX.GetPlayerFromIdentifier(identifier)
    local player = exports['xc_core']:GetPlayerByIdentifier(identifier)
    if not player then return nil end
    return ESX._WrapPlayer(player, player.source)
end

function ESX.GetPlayers()
    local sources = {}
    for src, _ in pairs(exports['xc_core']:GetPlayers()) do
        table.insert(sources, src)
    end
    return sources
end

function ESX.GetJob(jobName)
    return exports['xc_core']:GetJob(jobName)
end

function ESX._WrapPlayer(player, source)
    local xPlayer = {}

    xPlayer.source      = source
    xPlayer.identifier  = player.identifier
    xPlayer.name        = player.name.full
    xPlayer.group       = player.group

    
    xPlayer.job = {
        name       = player.job.name,
        label      = player.job.label,
        grade      = player.job.grade,
        grade_name = player.job.gradeLabel,
        grade_label= player.job.gradeLabel,
        salary     = player.job.salary,
        isBoss     = player.job.isBoss,
    }

    
    xPlayer.accounts = {
        { name='money',       label='Contanti',     money=player.money.cash },
        { name='bank',        label='Banca',        money=player.money.bank },
        { name='black_money', label='Soldi Sporchi',money=player.money.black_money },
    }

    
    function xPlayer.getMoney()
        return player.money.cash
    end

    function xPlayer.setMoney(amount)
        exports['xc_core']:SetMoney(source, 'cash', amount)
    end

    function xPlayer.addMoney(amount, reason)
        exports['xc_core']:AddMoney(source, 'cash', amount, reason)
    end

    function xPlayer.removeMoney(amount, reason)
        return exports['xc_core']:RemoveMoney(source, 'cash', amount, reason)
    end

    function xPlayer.getAccount(accountName)
        local map = { money='cash', bank='bank', black_money='black_money' }
        local key = map[accountName] or accountName
        return { money = player.money[key] or 0 }
    end

    function xPlayer.addAccountMoney(accountName, amount, reason)
        local map = { money='cash', bank='bank', black_money='black_money' }
        exports['xc_core']:AddMoney(source, map[accountName] or accountName, amount, reason)
    end

    function xPlayer.removeAccountMoney(accountName, amount, reason)
        local map = { money='cash', bank='bank', black_money='black_money' }
        return exports['xc_core']:RemoveMoney(source, map[accountName] or accountName, amount, reason)
    end

    
    function xPlayer.setJob(jobName, grade)
        exports['xc_core']:SetJob(source, jobName, grade)
        xPlayer.job.name  = jobName
        xPlayer.job.grade = grade
    end

    function xPlayer.getJob()
        return xPlayer.job
    end

    
    function xPlayer.getGroup()
        return player.group
    end

    function xPlayer.setGroup(group)
        player.group = group
    end

    
    function xPlayer.getInventory()
        return exports['xc_inventory'] and exports['xc_inventory']:GetInventory(source) or {}
    end

    function xPlayer.addInventoryItem(item, count)
        if exports['xc_inventory'] then
            exports['xc_inventory']:AddItem(source, item, count)
        end
    end

    function xPlayer.removeInventoryItem(item, count)
        if exports['xc_inventory'] then
            return exports['xc_inventory']:RemoveItem(source, item, count)
        end
        return false
    end

    function xPlayer.canCarryItem(item, count)
        if exports['xc_inventory'] then
            return exports['xc_inventory']:CanCarry(source, item, count)
        end
        return true
    end

    function xPlayer.getInventoryItem(item)
        if exports['xc_inventory'] then
            return exports['xc_inventory']:GetItem(source, item)
        end
        return nil
    end

    
    function xPlayer.showNotification(msg, type)
        TriggerClientEvent('xc_notify:send', source, { type=type or 'info', msg=msg })
    end

    function xPlayer.triggerEvent(event, ...)
        TriggerClientEvent(event, source, ...)
    end

    return xPlayer
end

ESX.RegisterServerCallback = function(name, cb)
    exports['xc_core']:RegisterCallback(name, function(source, data, resolve)
        cb(source, resolve, data)
    end)
end

ESX.TriggerServerCallback = function(name, cb, ...)
    
    XCoreUtils.Log('bridge', 'ESX.TriggerServerCallback chiamato lato server — usa il client bridge', 'warn')
end

ESX.Trace = function(msg)
    XCoreUtils.Log('esx_bridge', msg)
end

_ENV.ESX = ESX

exports('getSharedObject', function()
    return ESX
end)

XCoreUtils.Log('bridge', 'ESX Bridge (server) attivo')
