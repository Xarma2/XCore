local itemCatalog = {}

local inventories = {}

local function LoadItemCatalog()
    local rows = exports.oxmysql:executeSync('SELECT * FROM xcore_items')
    itemCatalog = {}
    for _, row in ipairs(rows or {}) do
        itemCatalog[row.name] = {
            name        = row.name,
            label       = row.label,
            weight      = row.weight,
            stack       = row.stack == 1,
            usable      = row.usable == 1,
            description = row.description,
            image       = row.image,
        }
    end
    XCoreUtils.Log('inventory', ('Caricati %d item dal catalogo'):format(#(rows or {})))
end

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    LoadItemCatalog()
end)

local function GetInventory(charId)
    if inventories[charId] then return inventories[charId] end
    
    local row = exports.oxmysql:executeSync(
        'SELECT inventory FROM xcore_characters WHERE id = ? LIMIT 1', { charId }
    )
    local inv = { slots = {}, weight = 0 }
    if row and row[1] and row[1].inventory then
        local decoded = XCoreUtils.SafeDecode(row[1].inventory)
        if decoded then inv = decoded end
    end
    
    local totalWeight = 0
    for _, slot in pairs(inv.slots or {}) do
        local item = itemCatalog[slot.name]
        if item then
            totalWeight = totalWeight + (item.weight * (slot.count or 1))
        end
    end
    inv.weight = totalWeight
    inventories[charId] = inv
    return inv
end

local function SaveInventory(charId)
    local inv = inventories[charId]
    if not inv then return end
    exports.oxmysql:execute(
        'UPDATE xcore_characters SET inventory = ? WHERE id = ?',
        { json.encode(inv), charId }
    )
end

local function GetTotalWeight(inv)
    local w = 0
    for _, slot in pairs(inv.slots or {}) do
        local item = itemCatalog[slot.name]
        if item then w = w + (item.weight * (slot.count or 1)) end
    end
    return w
end

local function FindItemSlot(inv, itemName)
    for slotId, slot in pairs(inv.slots) do
        if slot.name == itemName then return slotId, slot end
    end
    return nil, nil
end

local function FindEmptySlot(inv)
    for i = 1, XCoreConfig.InventorySlots do
        if not inv.slots[i] then return i end
    end
    return nil
end

exports('GetInventory', function(source)
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return nil end
    return GetInventory(player.charId)
end)

exports('GetItem', function(source, itemName)
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return nil end
    local inv = GetInventory(player.charId)
    local _, slot = FindItemSlot(inv, itemName)
    return slot
end)

exports('HasItem', function(source, itemName, count)
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return false end
    local inv = GetInventory(player.charId)
    count = count or 1
    local total = 0
    for _, slot in pairs(inv.slots) do
        if slot.name == itemName then total = total + (slot.count or 1) end
    end
    return total >= count
end)

exports('CanCarry', function(source, itemName, count)
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return false end
    local item = itemCatalog[itemName]
    if not item then return false end
    local inv = GetInventory(player.charId)
    local addWeight = item.weight * (count or 1)
    return (inv.weight + addWeight) <= XCoreConfig.MaxInventoryWeight
end)

exports('AddItem', function(source, itemName, count, metadata)
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return false end
    local item = itemCatalog[itemName]
    if not item then
        XCoreUtils.Log('inventory', ('Item non trovato: %s'):format(itemName), 'warn')
        return false
    end
    count = count or 1
    local inv = GetInventory(player.charId)
    local addWeight = item.weight * count

    if (inv.weight + addWeight) > XCoreConfig.MaxInventoryWeight then
        TriggerClientEvent('xc_notify:send', source, { type='error', msg='Stai portando troppo peso!' })
        return false
    end

    
    if item.stack then
        local slotId, existing = FindItemSlot(inv, itemName)
        if slotId then
            inv.slots[slotId].count = (existing.count or 1) + count
            inv.weight = inv.weight + addWeight
            SaveInventory(player.charId)
            TriggerClientEvent('xc_inventory:update', source, inv)
            return true
        end
    end

    
    local slotId = FindEmptySlot(inv)
    if not slotId then
        TriggerClientEvent('xc_notify:send', source, { type='error', msg='Inventario pieno!' })
        return false
    end

    inv.slots[slotId] = {
        name     = itemName,
        label    = item.label,
        count    = count,
        weight   = item.weight,
        metadata = metadata or {},
        image    = item.image,
    }
    inv.weight = inv.weight + addWeight
    SaveInventory(player.charId)
    TriggerClientEvent('xc_inventory:update', source, inv)
    TriggerClientEvent('xc_notify:send', source, {
        type='success', msg=('Ricevuto: %s x%d'):format(item.label, count)
    })
    return true
end)

exports('RemoveItem', function(source, itemName, count)
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return false end
    count = count or 1
    local inv = GetInventory(player.charId)
    local slotId, slot = FindItemSlot(inv, itemName)
    if not slotId or (slot.count or 1) < count then return false end

    local item = itemCatalog[itemName]
    local removeWeight = item and (item.weight * count) or 0

    if (slot.count or 1) - count <= 0 then
        inv.slots[slotId] = nil
    else
        inv.slots[slotId].count = slot.count - count
    end
    inv.weight = math.max(0, inv.weight - removeWeight)
    SaveInventory(player.charId)
    TriggerClientEvent('xc_inventory:update', source, inv)
    return true
end)

exports('GetItemCatalog', function()
    return itemCatalog
end)

exports['xc_core']:RegisterCallback('xc_inventory:open', function(source, data, resolve)
    local player = exports['xc_core']:GetPlayer(source)
    if not player then return resolve(nil) end
    resolve({
        inventory = GetInventory(player.charId),
        catalog   = itemCatalog,
        maxWeight = XCoreConfig.MaxInventoryWeight,
        maxSlots  = XCoreConfig.InventorySlots,
    })
end)

exports['xc_core']:RegisterCallback('xc_inventory:useItem', function(source, data, resolve)
    if not data or not data.itemName then return resolve(false) end
    local item = itemCatalog[data.itemName]
    if not item or not item.usable then return resolve(false) end
    
    local ok = exports['xc_inventory']:RemoveItem(source, data.itemName, 1)
    if ok then
        TriggerEvent('xc_inventory:itemUsed', source, data.itemName, data.metadata)
        TriggerClientEvent('xc_inventory:itemUsed', source, data.itemName)
    end
    resolve(ok)
end)

exports['xc_core']:RegisterCallback('xc_inventory:dropItem', function(source, data, resolve)
    if not data or not data.itemName then return resolve(false) end
    local ok = exports['xc_inventory']:RemoveItem(source, data.itemName, data.count or 1)
    if ok then
        
        TriggerEvent('xc_inventory:itemDropped', source, data.itemName, data.count or 1)
    end
    resolve(ok)
end)

AddEventHandler('xc_core:playerDropped', function(source, player)
    if player and player.charId then
        SaveInventory(player.charId)
        inventories[player.charId] = nil
    end
end)

XCoreUtils.Log('inventory', 'Inventory module avviato')
