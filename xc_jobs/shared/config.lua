XCoreJobsConfig = {}

XCoreJobsConfig.EnableDuty = true

XCoreJobsConfig.DefaultDuty = false

XCoreJobsConfig.AlwaysOnDuty = { 'unemployed' }

XCoreJobsConfig.BossMenuLocations = {
    police = {
        coords  = vector3(457.5, -987.3, 30.7),
        heading = 0.0,
        label   = 'Gestione Personale — Polizia',
    },
    ambulance = {
        coords  = vector3(307.0, -597.0, 43.3),
        heading = 0.0,
        label   = 'Gestione Personale — Ospedale',
    },
    mechanic = {
        coords  = vector3(-350.0, -133.0, 39.0),
        heading = 0.0,
        label   = 'Gestione Personale — Officina',
    },
}
