function SendNUIMessage(resource, action, data)
    local msg = data or {}
    msg.action = action
    SendNUIMessage(msg)
end

function SetNUIFocus(state, cursor)
    SetNuiFocus(state, cursor or state)
    SetNuiFocusKeepInput(false)
end

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)
