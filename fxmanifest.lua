fx_version 'cerulean'
game 'gta5'

author 'GrossBean'
description 'ChopShop for QB-Core Framework'
version '2025'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}
