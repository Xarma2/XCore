local usableItems = {}

function RegisterUsableItem(itemName, cb)
    usableItems[itemName] = cb
end

AddEventHandler('xc_inventory:itemUsed', function(source, itemName, metadata)
    local cb = usableItems[itemName]
    if cb then
        local ok, err = pcall(cb, source, metadata)
        if not ok then
            XCoreUtils.Log('inventory', ('Errore uso item %s: %s'):format(itemName, err), 'error')
        end
    end
end)

exports('RegisterUsableItem', RegisterUsableItem)

RegisterUsableItem('water', function(source, metadata)
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return end
    player:SetStatus('thirst', math.min(100, player:GetStatus('thirst') + 30))
    TriggerServerEvent('xc_core:server:updateStatus', { thirst = player:GetStatus('thirst') })
    TriggerClientEvent('xc_notify:send', source, { type='success', msg='Hai bevuto dell\'acqua. +30 sete' })
end)

RegisterUsableItem('bread', function(source, metadata)
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return end
    player:SetStatus('hunger', math.min(100, player:GetStatus('hunger') + 25))
    TriggerClientEvent('xc_notify:send', source, { type='success', msg='Hai mangiato del pane. +25 fame' })
end)

RegisterUsableItem('bandage', function(source, metadata)
    local ped = GetPlayerPed(source)
    local health = GetEntityHealth(ped)
    if health < 200 then
        SetEntityHealth(ped, math.min(200, health + 20))
    end
    TriggerClientEvent('xc_notify:send', source, { type='success', msg='Hai usato una benda. +20 HP' })
end)

RegisterUsableItem('medikit', function(source, metadata)
    local ped = GetPlayerPed(source)
    SetEntityHealth(ped, 200)
    TriggerClientEvent('xc_notify:send', source, { type='success', msg='Sei stato curato completamente.' })
end)

RegisterUsableItem('phone', function(source, metadata)
    TriggerClientEvent('xc_phone:open', source)
end)
