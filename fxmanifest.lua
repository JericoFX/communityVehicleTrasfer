fx_version 'cerulean'
games { 'rdr3', 'gta5' }

mod 'VehicleCommunity'
version '1.0.0'

client_scripts {
    'client/init.lua',
}
shared_script { "@ox_lib/init.lua", "config/init.lua" }
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/init.lua',

}
files {
    'locales/*.json',
    "client/modules/*.lua",
}
lua54 'yes'
