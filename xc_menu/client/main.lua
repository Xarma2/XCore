local menuOpen    = false
local progressCb  = nil
local progressActive = false

function OpenContextMenu(data, onSelect, onClose)
    if menuOpen then return end
    menuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action   = 'openContext',
        title    = data.title or 'Menu',
        elements = data.elements or {},
    })
    
    _G['__xc_menu_onSelect'] = onSelect
    _G['__xc_menu_onClose']  = onClose
end

function CloseContextMenu()
    if not menuOpen then return end
    menuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action='closeContext' })
    if _G['__xc_menu_onClose'] then _G['__xc_menu_onClose']() end
end

RegisterNUICallback('xc_menu:selectElement', function(data, cb)
    cb('ok')
    menuOpen = false
    SetNuiFocus(false, false)
    if _G['__xc_menu_onSelect'] then
        _G['__xc_menu_onSelect'](data)
    end
end)

RegisterNUICallback('xc_menu:closeContext', function(data, cb)
    cb('ok')
    menuOpen = false
    SetNuiFocus(false, false)
    if _G['__xc_menu_onClose'] then _G['__xc_menu_onClose']() end
end)

function Progressbar(data, onFinish, onCancel)
    if progressActive then return end
    progressActive = true
    progressCb = { finish=onFinish, cancel=onCancel }
    SendNUIMessage({
        action   = 'startProgress',
        label    = data.label    or 'Caricamento...',
        duration = data.duration or 3000,
        canCancel= data.canCancel ~= false,
    })
    
    if data.disableMovement then
        DisablePlayerFiring(PlayerId(), true)
    end
end

RegisterNUICallback('xc_menu:progressFinish', function(data, cb)
    cb('ok')
    progressActive = false
    if progressCb and progressCb.finish then progressCb.finish() end
    progressCb = nil
end)

RegisterNUICallback('xc_menu:progressCancel', function(data, cb)
    cb('ok')
    progressActive = false
    if progressCb and progressCb.cancel then progressCb.cancel() end
    progressCb = nil
end)

local radialItems = {}

function AddRadialItem(item)
    table.insert(radialItems, item)
end

function RemoveRadialItem(id)
    for i, item in ipairs(radialItems) do
        if item.id == id then table.remove(radialItems, i) return end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 303) and not menuOpen then  
            if #radialItems > 0 then
                menuOpen = true
                SetNuiFocus(true, false)
                SendNUIMessage({
                    action = 'openRadial',
                    items  = radialItems,
                })
            end
        end
    end
end)

RegisterNUICallback('xc_menu:radialSelect', function(data, cb)
    cb('ok')
    menuOpen = false
    SetNuiFocus(false, false)
    for _, item in ipairs(radialItems) do
        if item.id == data.id and item.onSelect then
            item.onSelect()
        end
    end
end)

RegisterNUICallback('xc_menu:closeRadial', function(data, cb)
    cb('ok')
    menuOpen = false
    SetNuiFocus(false, false)
end)

AddEventHandler('xc_menu:open',        function(data) OpenContextMenu(data, data.onSelect, data.onClose) end)
AddEventHandler('xc_menu:close',       function()     CloseContextMenu() end)
AddEventHandler('xc_menu:progressbar', function(data) Progressbar(data, data.onFinish, data.onCancel) end)

exports('OpenContextMenu', OpenContextMenu)
exports('CloseContextMenu', CloseContextMenu)
exports('Progressbar', Progressbar)
exports('AddRadialItem', AddRadialItem)
exports('RemoveRadialItem', RemoveRadialItem)
exports('IsMenuOpen', function() return menuOpen end)
