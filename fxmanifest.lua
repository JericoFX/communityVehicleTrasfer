fx_version 'cerulean'
games { 'rdr3', 'gta5' }
author 'JericoFX for the Order!'
description 'Order Vehicle Transfer Contract - Secure vehicle ownership transfer system'

name 'Order Vehicle Transfer Contract'
version '1.0.0'

-- Dependencies
dependencies {
    'ox_lib',
    'ox_target',
    'oxmysql'
}

-- Shared scripts
shared_scripts {
    '@ox_lib/init.lua',
    'config/init.lua'
}

-- Client scripts
client_scripts {
    'client/init.lua'
}

-- Server scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/init.lua'
}

-- UI
ui_page 'ui/index.html'

-- Files
files {
    'locale/*.json',
    'ui/index.html',
    'ui/app.css',
    'ui/js/*.js'
}

-- Lua version
lua54 'yes'
