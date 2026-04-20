local onDuty = XCoreJobsConfig.DefaultDuty

function IsOnDuty()
    return onDuty
end

function SetDuty(state)
    onDuty = state
    TriggerServerEvent('xc_jobs:server:setDuty', state)
    TriggerEvent('xc_jobs:dutyChanged', state)
    local msg = state and 'Sei entrato in servizio.' or 'Sei uscito dal servizio.'
    TriggerEvent('xc_notify:send', { type = state and 'success' or 'info', msg = msg })
end

function ToggleDuty()
    local data = exports['xc_core']:GetPlayerData()
    if not data then return end
    
    if XCoreUtils.TableContains(XCoreJobsConfig.AlwaysOnDuty, data.job.name) then
        TriggerEvent('xc_notify:send', { type='info', msg='Non puoi modificare il duty per questo lavoro.' })
        return
    end
    SetDuty(not onDuty)
end

RegisterCommand('duty', function()
    ToggleDuty()
end, false)

exports('IsOnDuty', IsOnDuty)
exports('SetDuty', SetDuty)
exports('ToggleDuty', ToggleDuty)
