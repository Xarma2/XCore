local hudVisible = true
local lastData   = {}

function SetHUDVisible(state)
    hudVisible = state
    SendNUIMessage({ action = state and 'showHUD' or 'hideHUD' })
end

AddEventHandler('xc_hud:update', function(data)
    lastData = data or {}
    SendNUIMessage({
        action = 'updateAll',
        data   = {
            name   = data.name and data.name.full or '',
            job    = data.job and data.job.label or '',
            cash   = data.money and data.money.cash or 0,
            status = data.status or {},
        }
    })
end)

AddEventHandler('xc_hud:moneyUpdated', function(money)
    SendNUIMessage({ action='updateMoney', cash=money.cash, bank=money.bank })
end)

AddEventHandler('xc_hud:statusUpdated', function(status)
    SendNUIMessage({ action='updateStatus', status=status })
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if hudVisible then
            local ped    = PlayerPedId()
            local health = math.floor(((GetEntityHealth(ped) - 100) / 100) * 100)
            local armor  = GetPedArmour(ped)
            local veh    = GetVehiclePedIsIn(ped, false)
            local speed  = 0
            if veh ~= 0 then
                speed = math.floor(GetEntitySpeed(veh) * 3.6)  
            end
            SendNUIMessage({
                action = 'updateVitals',
                health = math.max(0, health),
                armor  = armor,
                speed  = speed,
                inVehicle = veh ~= 0,
            })
        end
    end
end)

AddEventHandler('xc_multichar:open', function()  SetHUDVisible(false) end)
AddEventHandler('xc_multichar:close', function() SetHUDVisible(true)  end)

exports('SetHUDVisible', SetHUDVisible)
exports('IsHUDVisible',  function() return hudVisible end)
