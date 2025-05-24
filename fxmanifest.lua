fx_version 'cerulean'
games { 'rdr3', 'gta5' }
author 'JericoFX for the Order!'
description 'Order Vehicle Contract'

mod 'Order Vehicle Contract'
version '1.0.0'

client_scripts {
    'client/init.lua',
}
shared_script { "@ox_lib/init.lua", "config/init.lua" }
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/init.lua',

}
ui_page 'ui/index.html'
files {
    'locales/*.json',
    "ui/index.html",
    "ui/app.css",
    "ui/js/*.js",
    "client/modules/*.lua",
}
lua54 'yes'
