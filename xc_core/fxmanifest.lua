fx_version 'cerulean'
game 'gta5'

name        'xc_core'
description 'XCore Framework — Core Module'
version     '1.0.0'
author      'Xarma'

dependencies {
    'oxmysql',
    'xc_shared',
}

shared_scripts {
    '@xc_shared/config.lua',
    '@xc_shared/utils.lua',
    'shared/player_class.lua',
}

server_scripts {
    'server/main.lua',
    'server/player_manager.lua',
    'server/callbacks.lua',
    'server/commands.lua',
    'server/events.lua',
}

client_scripts {
    'client/main.lua',
    'client/callbacks.lua',
    'client/events.lua',
    'client/nui.lua',
}
