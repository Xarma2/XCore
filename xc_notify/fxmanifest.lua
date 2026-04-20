fx_version 'cerulean'
game 'gta5'

name        'xc_notify'
description 'XCore Framework — Notification System'
version     '1.0.0'
author      'Xarma'

dependencies {
    'xc_shared',
}

shared_scripts {
    '@xc_shared/config.lua',
    '@xc_shared/utils.lua',
}

client_scripts {
    'client/main.lua',
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/app.js',
}
