fx_version 'cerulean'
game 'gta5'

name        'xc_jobs'
description 'XCore Framework — Jobs System'
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
    'shared/config.lua',
}

server_scripts {
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
    'client/duty.lua',
}
