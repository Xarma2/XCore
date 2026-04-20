fx_version 'cerulean'
game 'gta5'

name        'xc_bridge'
description 'XCore Framework — ESX & QBCore Compatibility Bridge'
version     '1.0.0'
author      'Xarma'

dependencies {
    'xc_core',
    'xc_shared',
}

shared_scripts {
    '@xc_shared/config.lua',
    '@xc_shared/utils.lua',
}

server_scripts {
    'server/esx_bridge.lua',
    'server/qbcore_bridge.lua',
}

client_scripts {
    'client/esx_bridge.lua',
    'client/qbcore_bridge.lua',
}
