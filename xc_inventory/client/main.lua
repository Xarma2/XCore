local invOpen = false

RegisterCommand('inv', function()
    if invOpen then return end
    exports['xc_core']:TriggerCallback('xc_inventory:open', {}, function(data)
        if not data then return end
        invOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            action    = 'openInventory',
            inventory = data.inventory,
            catalog   = data.catalog,
            maxWeight = data.maxWeight,
            maxSlots  = data.maxSlots,
        })
    end)
end, false)

RegisterNetEvent('xc_inventory:update', function(inv)
    if invOpen then
        SendNUIMessage({ action='updateInventory', inventory=inv })
    end
    TriggerEvent('xc_inventory:updated', inv)
end)

RegisterNetEvent('xc_inventory:itemUsed', function(itemName)
    TriggerEvent('xc_inventory:client:itemUsed', itemName)
end)

RegisterNUICallback('xc_inventory:close', function(data, cb)
    invOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('xc_inventory:useItem', function(data, cb)
    exports['xc_core']:TriggerCallback('xc_inventory:useItem', {
        itemName = data.itemName,
        metadata = data.metadata,
    }, function(res)
        cb(res)
    end)
end)

RegisterNUICallback('xc_inventory:dropItem', function(data, cb)
    exports['xc_core']:TriggerCallback('xc_inventory:dropItem', {
        itemName = data.itemName,
        count    = data.count or 1,
    }, function(res)
        cb(res)
    end)
end)

exports('IsOpen', function() return invOpen end)
