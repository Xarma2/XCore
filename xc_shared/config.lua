XCoreConfig = {}

XCoreConfig.Version = '1.0.0'

XCoreConfig.Identifier = 'license'

XCoreConfig.MaxCharacters = 3

XCoreConfig.DefaultSpawn = {
    x = -269.4,
    y = -955.3,
    z = 31.2,
    heading = 205.0
}

XCoreConfig.Currency = {
    symbol = '€',
    prefix = false,  
    separator = '.',
    decimal = ','
}

XCoreConfig.StartingCash  = 5000
XCoreConfig.StartingBank  = 10000

XCoreConfig.MaxInventoryWeight = 30000  

XCoreConfig.InventorySlots = 41

XCoreConfig.HotbarSlots = 5

XCoreConfig.PaycheckInterval = 30 * 60 * 1000

XCoreConfig.AdminGroups = {
    'superadmin',
    'admin',
    'moderator',
}

XCoreConfig.Permissions = {
    superadmin = { kick=true,  ban=true,  unban=true,  noclip=true,  god=true,  spectate=true,  teleport=true,  setjob=true,  givemoney=true,  revive=true },
    admin      = { kick=true,  ban=true,  unban=false, noclip=true,  god=true,  spectate=true,  teleport=true,  setjob=true,  givemoney=true,  revive=true },
    moderator  = { kick=true,  ban=false, unban=false, noclip=false, god=false, spectate=true,  teleport=false, setjob=false, givemoney=false, revive=true },
    user       = { kick=false, ban=false, unban=false, noclip=false, god=false, spectate=false, teleport=false, setjob=false, givemoney=false, revive=false },
}

XCoreConfig.Garages = {
    pillbox = {
        label   = 'Pillbox Hill',
        coords  = vector3(215.0, -810.0, 30.0),
        spawn   = vector4(215.0, -800.0, 30.0, 0.0),
        type    = 'car',
    },
    airport = {
        label   = 'Aeroporto',
        coords  = vector3(-1044.0, -2745.0, 20.0),
        spawn   = vector4(-1044.0, -2735.0, 20.0, 0.0),
        type    = 'car',
    },
    sandy = {
        label   = 'Sandy Shores',
        coords  = vector3(1866.0, 3692.0, 34.0),
        spawn   = vector4(1866.0, 3702.0, 34.0, 0.0),
        type    = 'car',
    },
    impound = {
        label   = 'Deposito',
        coords  = vector3(404.0, -1640.0, 29.0),
        spawn   = vector4(404.0, -1630.0, 29.0, 0.0),
        type    = 'car',
        impound = true,
    },
}

XCoreConfig.HUD = {
    health    = true,
    armor     = true,
    hunger    = true,
    thirst    = true,
    stress    = true,
    stamina   = true,
    cash      = true,
    minimap   = true,
    speedometer = true,
}

XCoreConfig.DefaultStatus = {
    hunger = 100,
    thirst = 100,
    stress = 0,
    stamina = 100,
}

XCoreConfig.StatusDecay = {
    hunger  = 0.5,
    thirst  = 1.0,
    stress  = 0.0,
    stamina = 0.0,
}
