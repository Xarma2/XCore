local bossMenuOpen = false

RegisterNetEvent('xc_jobs:openBossMenu', function()
    if bossMenuOpen then return end
    local data = exports['xc_core']:GetPlayerData()
    if not data or not data.job.isBoss then
        TriggerEvent('xc_notify:send', { type='error', msg='Non hai accesso al boss menu.' })
        return
    end

    exports['xc_core']:TriggerCallback('xc_jobs:getEmployees', {}, function(res)
        if not res or not res.success then
            TriggerEvent('xc_notify:send', { type='error', msg=res and res.error or 'Errore' })
            return
        end
        bossMenuOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            action    = 'openBossMenu',
            job       = data.job,
            employees = res.employees,
        })
    end)
end)

RegisterNUICallback('xc_jobs:closeBossMenu', function(data, cb)
    bossMenuOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('xc_jobs:setGrade', function(data, cb)
    exports['xc_core']:TriggerCallback('xc_jobs:setEmployeeGrade', {
        charId = data.charId,
        grade  = data.grade,
    }, function(res)
        cb(res)
        if res and res.success then
            TriggerEvent('xc_notify:send', { type='success', msg='Grado aggiornato.' })
        else
            TriggerEvent('xc_notify:send', { type='error', msg=res and res.error or 'Errore' })
        end
    end)
end)

RegisterNUICallback('xc_jobs:fire', function(data, cb)
    exports['xc_core']:TriggerCallback('xc_jobs:fireEmployee', { charId = data.charId }, function(res)
        cb(res)
        if res and res.success then
            TriggerEvent('xc_notify:send', { type='success', msg='Dipendente licenziato.' })
        else
            TriggerEvent('xc_notify:send', { type='error', msg=res and res.error or 'Errore' })
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local data = exports['xc_core']:GetPlayerData()
        if data and data.job.isBoss then
            local bossLoc = XCoreJobsConfig.BossMenuLocations[data.job.name]
            if bossLoc then
                local ped    = PlayerPedId()
                local coords = GetEntityCoords(ped)
                local dist   = #(coords - bossLoc.coords)
                DrawMarker(1, bossLoc.coords.x, bossLoc.coords.y, bossLoc.coords.z - 1.0, 0,0,0, 0,0,0, 1.0,1.0,0.5, 0,170,255,80, false, true, 2, false, nil, nil, false)
                if dist < 2.0 then
                    TriggerEvent('xc_notify:send', { type='info', msg='Premi ~INPUT_CONTEXT~ per aprire il Boss Menu', duration=1000 })
                    if IsControlJustReleased(0, 38) then
                        TriggerEvent('xc_jobs:openBossMenu')
                    end
                end
            end
        else
            Citizen.Wait(2000)
        end
    end
end)
