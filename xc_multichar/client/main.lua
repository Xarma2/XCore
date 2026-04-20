local isOpen = false

AddEventHandler('xc_multichar:open', function()
    if isOpen then return end
    isOpen = true

    
    FreezeEntityPosition(PlayerPedId(), true)
    SetPlayerControl(PlayerId(), false, 0)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    
    local cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', -1037.0, -2738.0, 13.0, 0, 0, 0, 50.0, false, 2)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)

    
    exports['xc_core']:TriggerCallback('xc_core:getCharacters', {}, function(chars)
        SetNuiFocus(true, true)
        SendNUIMessage({
            action     = 'open',
            characters = chars or {},
            maxSlots   = XCoreConfig.MaxCharacters,
        })
    end)
end)

RegisterNetEvent('xc_multichar:close', function()
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action='close' })
    FreezeEntityPosition(PlayerPedId(), false)
    SetPlayerControl(PlayerId(), true, 0)
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(GetRenderingCam(), false)
    TriggerEvent('xc_multichar:closed')
end)

RegisterNUICallback('xc_multichar:select', function(data, cb)
    cb('ok')
    TriggerServerEvent('xc_multichar:server:selectCharacter', data.slot)
end)

RegisterNUICallback('xc_multichar:create', function(data, cb)
    exports['xc_core']:TriggerCallback('xc_core:createCharacter', {
        slot      = data.slot,
        firstname = data.firstname,
        lastname  = data.lastname,
        dob       = data.dob,
        gender    = data.gender,
    }, function(res)
        cb(res)
        if res and res.success then
            
            exports['xc_core']:TriggerCallback('xc_core:getCharacters', {}, function(chars)
                SendNUIMessage({ action='updateCharacters', characters=chars or {} })
            end)
        end
    end)
end)

RegisterNUICallback('xc_multichar:delete', function(data, cb)
    exports['xc_core']:TriggerCallback('xc_core:deleteCharacter', { charId=data.charId }, function(res)
        cb(res)
        if res then
            exports['xc_core']:TriggerCallback('xc_core:getCharacters', {}, function(chars)
                SendNUIMessage({ action='updateCharacters', characters=chars or {} })
            end)
        end
    end)
end)
