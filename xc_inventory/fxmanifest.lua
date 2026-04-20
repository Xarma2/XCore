fx_version 'cerulean'
game 'gta5'

name        'xc_inventory'
description 'XCore Framework — Inventory System'
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
    'server/items.lua',
}

client_scripts {
    'client/main.lua',
    'client/hotbar.lua',
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/app.js',
}
