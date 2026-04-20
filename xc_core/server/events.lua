RegisterNetEvent('xc_core:server:requestSpawn', function(charSlot)
    local source = source
    TriggerEvent('xc_core:server:playerLoaded', source, charSlot)
    
    TriggerEvent('xc_core:server:playerLoaded', source)
end)

RegisterNetEvent('xc_core:server:updateSkin', function(skinData)
    local source = source
    local player = XCorePlayers[source]
    if not player then return end
    player.skin = skinData
    exports.oxmysql:execute('UPDATE xcore_characters SET skin=? WHERE id=?', { json.encode(skinData), player.charId })
end)

RegisterNetEvent('xc_core:server:updateStatus', function(statusData)
    local source = source
    local player = XCorePlayers[source]
    if not player then return end
    for k, v in pairs(statusData) do
        player.status[k] = XCoreUtils.Clamp(v, 0, 100)
    end
end)

RegisterNetEvent('xc_core:server:updatePosition', function(pos)
    local source = source
    local player = XCorePlayers[source]
    if not player then return end
    player.position = pos
end)

RegisterNetEvent('xc_core:server:playerDied', function()
    local source = source
    local player = XCorePlayers[source]
    if not player then return end
    player.isDead = true
    Player(source).state:set('xcore:isDead', true, true)
    TriggerEvent('xc_core:playerDied', source, player)
end)

RegisterNetEvent('xc_core:server:playerRevived', function()
    local source = source
    local player = XCorePlayers[source]
    if not player then return end
    player.isDead = false
    Player(source).state:set('xcore:isDead', false, true)
    TriggerEvent('xc_core:playerRevived', source, player)
end)

RegisterNetEvent('xc_core:server:setMetadata', function(key, value)
    local source = source
    local player = XCorePlayers[source]
    if not player then return end
    player:SetMetadata(key, value)
end)
