XCoreLocalPlayer = nil

local isLoaded = false

function GetPlayerData()
    return XCoreLocalPlayer
end

RegisterNetEvent('xc_core:client:playerLoaded', function(data)
    XCoreLocalPlayer = data
    isLoaded = true

    
    local pos = data.position or XCoreConfig.DefaultSpawn
    local ped = PlayerPedId()

    RequestCollisionAtCoord(pos.x, pos.y, pos.z)
    SetEntityCoords(ped, pos.x, pos.y, pos.z, false, false, false, false)
    SetEntityHeading(ped, pos.heading or 0.0)
    FreezeEntityPosition(ped, false)
    SetPlayerControl(PlayerId(), true, 0)

    
    TriggerEvent('xc_core:client:loaded', data)
    TriggerEvent('xc_hud:update', data)

    XCoreUtils.Log('core', 'Player caricato lato client: ' .. data.name.full)
end)

RegisterNetEvent('xc_core:client:moneyUpdated', function(money)
    if XCoreLocalPlayer then
        XCoreLocalPlayer.money = money
        TriggerEvent('xc_hud:moneyUpdated', money)
    end
end)

RegisterNetEvent('xc_core:client:jobUpdated', function(job)
    if XCoreLocalPlayer then
        XCoreLocalPlayer.job = job
        TriggerEvent('xc_core:client:jobChanged', job)
    end
end)

RegisterNetEvent('xc_core:client:gangUpdated', function(gang)
    if XCoreLocalPlayer then
        XCoreLocalPlayer.gang = gang
    end
end)

RegisterNetEvent('xc_core:client:revive', function()
    local ped = PlayerPedId()
    ResurrectNetworkPlayer(PlayerId())
    SetEntityHealth(ped, 200)
    NetworkResurrectLocalPlayer(
        XCoreLocalPlayer and XCoreLocalPlayer.position and XCoreLocalPlayer.position.x or 0.0,
        XCoreLocalPlayer and XCoreLocalPlayer.position and XCoreLocalPlayer.position.y or 0.0,
        XCoreLocalPlayer and XCoreLocalPlayer.position and XCoreLocalPlayer.position.z or 0.0,
        0.0, true, false
    )
    if XCoreLocalPlayer then XCoreLocalPlayer.isDead = false end
    TriggerEvent('xc_core:client:revived')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000)  
        if isLoaded then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            TriggerServerEvent('xc_core:server:updatePosition', {
                x = coords.x, y = coords.y, z = coords.z, heading = heading
            })
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if isLoaded and XCoreLocalPlayer then
            local ped = PlayerPedId()
            local isDead = IsEntityDead(ped) or IsPlayerDead(PlayerId())
            if isDead and not XCoreLocalPlayer.isDead then
                XCoreLocalPlayer.isDead = true
                TriggerServerEvent('xc_core:server:playerDied')
                TriggerEvent('xc_core:client:died')
            end
        end
    end
end)

exports('GetPlayerData', GetPlayerData)
exports('IsLoaded', function() return isLoaded end)
