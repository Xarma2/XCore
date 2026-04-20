local pendingCallbacks = {}
local requestCounter   = 0

function TriggerCallback(name, data, cb, timeout)
    requestCounter = requestCounter + 1
    local id = requestCounter
    timeout = timeout or 10000

    pendingCallbacks[id] = {
        cb      = cb,
        expires = GetGameTimer() + timeout,
    }

    TriggerServerEvent('xc_core:server:triggerCallback', name, id, data)
end

RegisterNetEvent('xc_core:client:callbackResponse', function(requestId, result)
    local pending = pendingCallbacks[requestId]
    if pending then
        pendingCallbacks[requestId] = nil
        if pending.cb then
            pending.cb(result)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        local now = GetGameTimer()
        for id, pending in pairs(pendingCallbacks) do
            if now > pending.expires then
                XCoreUtils.Log('core', ('Callback timeout: id=%d'):format(id), 'warn')
                if pending.cb then pending.cb(nil) end
                pendingCallbacks[id] = nil
            end
        end
    end
end)

exports('TriggerCallback', TriggerCallback)
