local hotbar = {}  

AddEventHandler('xc_inventory:updated', function(inv)
    
    hotbar = {}
    local count = 0
    for slotId, slot in pairs(inv.slots or {}) do
        if count >= XCoreConfig.HotbarSlots then break end
        hotbar[count + 1] = slot
        count = count + 1
    end
    SendNUIMessage({ action='updateHotbar', hotbar=hotbar })
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for i = 1, XCoreConfig.HotbarSlots do
            
            if IsControlJustReleased(0, 156 + i) then
                local slot = hotbar[i]
                if slot then
                    exports['xc_core']:TriggerCallback('xc_inventory:useItem', {
                        itemName = slot.name,
                        metadata = slot.metadata,
                    }, function(res)
                        
                    end)
                end
            end
        end
    end
end)

exports('GetHotbar', function() return hotbar end)
