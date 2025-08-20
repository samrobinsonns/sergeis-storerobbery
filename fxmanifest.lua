fx_version 'cerulean'
game 'gta5'

author 'Sergei'
description 'Store Robbery Script with Cash Registers and Safes'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/cash_register.lua',
    'client/safe_robbery.lua',
    'client/minigame.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/cash_register.lua',
    'server/safe_robbery.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/cash_register.html',
    'html/cash_register.css',
    'html/cash_register.js',
    'html/sounds/*.ogg'
}

dependencies {
    'qb-core',
    'ox_lib',
    'oxmysql'
}

lua54 'yes'
