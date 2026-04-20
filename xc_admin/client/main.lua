local adminOpen  = false
local noclipOn   = false
local spectating = false
local specTarget = nil

RegisterCommand('admin', function()
    local data = exports['xc_core']:GetPlayerData()
    if not data then return end
    local groups = { superadmin=5, admin=4, moderator=3, helper=2, vip=1, user=0 }
    if (groups[data.group] or 0) < 2 then
        TriggerEvent('xc_notify:send', { type='error', msg='Non hai i permessi.' })
        return
    end
    if adminOpen then
        adminOpen = false
        SetNuiFocus(false, false)
        SendNUIMessage({ action='close' })
        return
    end
    exports['xc_core']:TriggerCallback('xc_admin:getPlayers', {}, function(players)
        adminOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            action  = 'open',
            players = players or {},
            myGroup = data.group,
        })
    end)
end, false)

RegisterNUICallback('xc_admin:close', function(data, cb)
    adminOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('xc_admin:kick', function(data, cb)
    TriggerServerEvent('xc_admin:server:kick', data.source, data.reason)
    cb('ok')
end)

RegisterNUICallback('xc_admin:ban', function(data, cb)
    TriggerServerEvent('xc_admin:server:ban', data.source, data.duration, data.reason)
    cb('ok')
end)

RegisterNUICallback('xc_admin:tp', function(data, cb)
    TriggerServerEvent('xc_admin:server:tp', data.source)
    cb('ok')
end)

RegisterNUICallback('xc_admin:spectate', function(data, cb)
    TriggerServerEvent('xc_admin:server:spectate', data.source)
    cb('ok')
end)

RegisterNUICallback('xc_admin:refresh', function(data, cb)
    exports['xc_core']:TriggerCallback('xc_admin:getPlayers', {}, function(players)
        cb(players or {})
    end)
end)

RegisterNetEvent('xc_admin:tpToPlayer', function(target)
    local ped = GetPlayerPed(GetPlayerFromServerId(target))
    if ped and ped ~= 0 then
        local coords = GetEntityCoords(ped)
        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z + 1.0, false, false, false, true)
    end
end)

RegisterNetEvent('xc_admin:tpToCoords', function(x, y, z)
    SetEntityCoords(PlayerPedId(), x, y, z, false, false, false, true)
end)

RegisterNetEvent('xc_admin:freeze', function(state)
    FreezeEntityPosition(PlayerPedId(), state)
    TriggerEvent('xc_notify:send', { type='info', msg=state and 'Sei stato freezato.' or 'Sei stato scongelato.' })
end)

RegisterNetEvent('xc_admin:heal', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, 200)
    SetPedArmour(ped, 100)
    TriggerEvent('xc_notify:send', { type='success', msg='Sei stato curato.' })
end)

RegisterNetEvent('xc_admin:revive', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, 200)
    NetworkResurrectLocalPlayer(GetEntityCoords(ped).x, GetEntityCoords(ped).y, GetEntityCoords(ped).z, GetEntityHeading(ped), true, false)
    TriggerEvent('xc_notify:send', { type='success', msg='Sei stato rianimato.' })
end)

RegisterNetEvent('xc_admin:toggleNoclip', function()
    noclipOn = not noclipOn
    TriggerEvent('xc_notify:send', { type='info', msg=noclipOn and 'Noclip attivato.' or 'Noclip disattivato.' })
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if noclipOn then
            local ped    = PlayerPedId()
            local speed  = IsControlPressed(0, 21) and 2.0 or 0.5  
            local fwd    = GetEntityForwardVector(ped)
            local coords = GetEntityCoords(ped)

            local x = coords.x + (fwd.x * (IsControlPressed(0, 32) and speed or IsControlPressed(0, 33) and -speed or 0))
            local y = coords.y + (fwd.y * (IsControlPressed(0, 32) and speed or IsControlPressed(0, 33) and -speed or 0))
            local z = coords.z + (IsControlPressed(0, 44) and speed or IsControlPressed(0, 46) and -speed or 0)

            SetEntityCoords(ped, x, y, z, false, false, false, false)
            SetEntityVelocity(ped, 0, 0, 0)
            SetEntityCollision(ped, false, false)
        end
    end
end)

RegisterNetEvent('xc_admin:spectate', function(target)
    if spectating then
        
        NetworkSetInSpectatorMode(false, PlayerPedId())
        spectating = false
        specTarget = nil
        TriggerEvent('xc_notify:send', { type='info', msg='Spectate disattivato.' })
    else
        local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
        if targetPed and targetPed ~= 0 then
            NetworkSetInSpectatorMode(true, targetPed)
            spectating = true
            specTarget = target
            TriggerEvent('xc_notify:send', { type='info', msg='Spectate attivato.' })
        end
    end
end)
