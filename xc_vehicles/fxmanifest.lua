fx_version 'cerulean'
game 'gta5'

name        'xc_vehicles'
description 'XCore Framework — Vehicles System'
version     '1.0.0'
author      'Xarma'

dependencies {
    'oxmysql',
    'xc_core',
    'xc_shared',
}

shared_scripts {
    '@xc_shared/config.lua',
    '@xc_shared/utils.lua',
}

server_scripts {
    'server/main.lua',
    'server/keys.lua',
}

client_scripts {
    'client/main.lua',
    'client/garage.lua',
    'client/keys.lua',
}
