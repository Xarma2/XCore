AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    
    Citizen.Wait(1000)
    TriggerEvent('xc_multichar:open')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)  
        if XCoreLocalPlayer and XCoreLocalPlayer.status then
            
            for key, decay in pairs(XCoreConfig.StatusDecay) do
                if decay > 0 and XCoreLocalPlayer.status[key] then
                    XCoreLocalPlayer.status[key] = XCoreUtils.Clamp(
                        XCoreLocalPlayer.status[key] - decay, 0, 100
                    )
                end
            end
            TriggerServerEvent('xc_core:server:updateStatus', XCoreLocalPlayer.status)
            TriggerEvent('xc_hud:statusUpdated', XCoreLocalPlayer.status)
        end
    end
end)
