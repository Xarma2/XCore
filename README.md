# XCore Framework

**Autore:** Xarma  
**Versione:** 1.0.0  
**Licenza:** Proprietaria — Tutti i diritti riservati

---

## Panoramica

XCore è un framework FiveM di nuova generazione, progettato per superare i limiti architetturali di ESX e QBCore. È costruito su tre principi fondamentali: **performance**, **modularità** e **compatibilità**.

---

## Struttura del Progetto

```
XCore/
├── xc_shared/          ← Config globale e utility condivise
├── xc_core/            ← Core: gestione giocatori, DB, statebags, callback
├── xc_bridge/          ← Compatibilità ESX e QBCore
├── xc_economy/         ← Economia: cash, banca, transazioni, società
├── xc_jobs/            ← Lavori, gradi, stipendi, boss menu
├── xc_inventory/       ← Inventario a slot con peso e hotbar
├── xc_vehicles/        ← Garage, proprietà veicoli, chiavi
├── xc_hud/             ← HUD in-game (NUI)
├── xc_notify/          ← Sistema notifiche (NUI)
├── xc_menu/            ← Context menu, radiale, progressbar (NUI)
├── xc_multichar/       ← Selezione personaggio multicharacter (NUI)
├── xc_admin/           ← Pannello admin, ban, kick, permessi (NUI)
└── xcore.sql           ← Schema database completo
```

---

## Requisiti

| Dipendenza | Versione | Note |
|---|---|---|
| **oxmysql** | 2.x+ | Obbligatorio per il database |
| **ox_lib** | 3.x+ | Raccomandato per UI aggiuntive |
| **mysql-async** | — | Alternativa a oxmysql (non ufficiale) |

---

## Installazione

**1. Importa il database**
```sql
-- Esegui xcore.sql nel tuo database MySQL
source /path/to/XCore/xcore.sql;
```

**2. Copia i moduli nella cartella resources**
```
resources/
  [xcore]/
    xc_shared/
    xc_core/
    xc_bridge/
    xc_economy/
    xc_jobs/
    xc_inventory/
    xc_vehicles/
    xc_hud/
    xc_notify/
    xc_menu/
    xc_multichar/
    xc_admin/
```

**3. Aggiungi al server.cfg (nell'ordine corretto)**
```cfg
ensure oxmysql
ensure xc_shared
ensure xc_core
ensure xc_bridge
ensure xc_economy
ensure xc_jobs
ensure xc_inventory
ensure xc_vehicles
ensure xc_notify
ensure xc_menu
ensure xc_hud
ensure xc_multichar
ensure xc_admin
```

**4. Configura il database in `xc_shared/config.lua`**
```lua
XCoreConfig.Database = {
    host     = '127.0.0.1',
    port     = 3306,
    database = 'xcore',
    username = 'root',
    password = 'password',
}
```

---

## Compatibilità ESX / QBCore

XCore include un **bridge layer** (`xc_bridge`) che espone le API di ESX e QBCore in modo che gli script esistenti continuino a funzionare senza modifiche.

### Utilizzo con script ESX
```lua
-- Gli script ESX funzionano automaticamente
ESX = exports['xc_bridge']:GetESX()
local xPlayer = ESX.GetPlayerFromId(source)
xPlayer.addMoney(1000)
```

### Utilizzo con script QBCore
```lua
-- Gli script QBCore funzionano automaticamente
QBCore = exports['xc_bridge']:GetCoreObject()
local Player = QBCore.Functions.GetPlayer(source)
Player.Functions.AddMoney('cash', 1000)
```

---

## API Principali (xc_core)

### Server-side

```lua
-- Ottieni un player
local player = exports['xc_core']:GetPlayer(source)

-- Ottieni tutti i player
local players = exports['xc_core']:GetPlayers()

-- Registra una callback
exports['xc_core']:RegisterCallback('myResource:myCallback', function(source, data, resolve)
    resolve({ success = true, data = 'example' })
end)
```

### Client-side

```lua
-- Ottieni i dati del player locale
local data = exports['xc_core']:GetPlayerData()

-- Trigger una callback
exports['xc_core']:TriggerCallback('myResource:myCallback', { key = 'value' }, function(result)
    print(result.data)
end)
```

### Metodi dell'oggetto Player

```lua
local player = exports['xc_core']:GetPlayer(source)

player:GetName()                    -- { first, last, full }
player:GetJob()                     -- { name, label, grade, salary, isBoss }
player:SetJob('police', 2)          -- Imposta lavoro e grado
player:GetMoney('cash')             -- Ottieni saldo
player:AddMoney('cash', 1000)       -- Aggiungi denaro
player:RemoveMoney('cash', 500)     -- Rimuovi denaro
player:GetGroup()                   -- Gruppo: user/vip/helper/moderator/admin/superadmin
player:SetGroup('admin')            -- Imposta gruppo
player:GetStatus('hunger')          -- Ottieni status (0-100)
player:SetStatus('hunger', 80)      -- Imposta status
player:Save()                       -- Salva su DB
```

---

## API Economy (xc_economy)

```lua
-- Server
exports['xc_economy']:AddMoney(source, 'cash', 1000)
exports['xc_economy']:RemoveMoney(source, 'cash', 500)
exports['xc_economy']:GetBalance(source, 'bank')
exports['xc_economy']:Transfer(fromSource, toSource, 'bank', 500)
```

---

## API Inventory (xc_inventory)

```lua
-- Server
exports['xc_inventory']:AddItem(source, 'water', 3)
exports['xc_inventory']:RemoveItem(source, 'water', 1)
exports['xc_inventory']:HasItem(source, 'water', 1)   -- boolean
exports['xc_inventory']:CanCarry(source, 'water', 5)  -- boolean

-- Registra item usabile
exports['xc_inventory']:RegisterUsableItem('myitem', function(source, metadata)
    -- logica utilizzo
end)
```

---

## API Vehicles (xc_vehicles)

```lua
-- Server
exports['xc_vehicles']:GetVehicles(charId)
exports['xc_vehicles']:GetVehicleByPlate('AB123CD')
exports['xc_vehicles']:BuyVehicle(source, 'adder', 'Bugatti', 'pillbox')
exports['xc_vehicles']:ImpoundVehicle('AB123CD')
exports['xc_vehicles']:GiveKeys(source, 'AB123CD')
exports['xc_vehicles']:RemoveKeys(source, 'AB123CD')
```

---

## API Menu (xc_menu)

```lua
-- Client
exports['xc_menu']:OpenContextMenu({
    title    = 'Il mio menu',
    elements = {
        { label='Opzione 1', value='opt1', icon='🔧', description='Descrizione' },
        { label='Opzione 2', value='opt2', disabled=true },
    }
}, function(selected)
    print('Selezionato:', selected.value)
end)

-- Progressbar
exports['xc_menu']:Progressbar({
    label       = 'Sto lavorando...',
    duration    = 5000,
    canCancel   = true,
}, function()
    print('Completato!')
end, function()
    print('Annullato!')
end)

-- Menu radiale
exports['xc_menu']:AddRadialItem({
    id       = 'myaction',
    label    = 'Azione',
    icon     = '🔧',
    onSelect = function()
        print('Azione eseguita!')
    end
})
```

---

## Gruppi e Permessi

| Gruppo | Livello | Accesso |
|---|---|---|
| `user` | 0 | Giocatore normale |
| `vip` | 1 | Funzioni VIP |
| `helper` | 2 | Pannello admin (sola lettura) |
| `moderator` | 3 | Kick, freeze, tp, spectate |
| `admin` | 4 | Ban, setjob, givemoney, unban |
| `superadmin` | 5 | Accesso completo, setgroup |

---

## Comandi Admin

| Comando | Permesso | Descrizione |
|---|---|---|
| `/admin` | helper+ | Apri pannello admin |
| `/kick [id] [motivo]` | moderator+ | Kicka un player |
| `/ban [id] [ore] [motivo]` | moderator+ | Banna un player |
| `/unban [identifier]` | admin+ | Rimuovi ban |
| `/setgroup [id] [gruppo]` | superadmin | Imposta gruppo |
| `/setjob [id] [job] [grade]` | admin+ | Imposta lavoro |
| `/givemoney [id] [tipo] [importo]` | admin+ | Dai denaro |
| `/tp [id\|x y z]` | moderator+ | Teleporta |
| `/spectate [id]` | moderator+ | Spectate |
| `/noclip` | moderator+ | Toggle noclip |
| `/freeze [id]` | moderator+ | Freeza player |
| `/unfreeze [id]` | moderator+ | Scongela player |
| `/heal [id?]` | moderator+ | Cura player |
| `/revive [id?]` | moderator+ | Reviva player |
| `/duty` | tutti | Toggle duty lavoro |

---

## Tasti Predefiniti

| Tasto | Funzione |
|---|---|
| `I` | Apri inventario |
| `Z` | Apri menu radiale |
| `L` | Lock/unlock veicolo vicino |
| `1-5` | Usa item hotbar |
| `F10` | Apri pannello admin |

---

## Changelog

### v1.0.0
- Release iniziale del framework XCore
- Tutti i moduli core implementati
- Bridge ESX/QBCore completo
- NUI Dark Tech per HUD, notifiche, menu, multichar, admin

---

*XCore Framework — Sviluppato da Xarma*
