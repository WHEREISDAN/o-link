fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'o-link'
author 'Oxide Studios'
description 'Oxide Studios framework bridge'
version '1.0.0'

escrow_ignore {
    'config.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'core/shared.lua',
    'modules/notify/shared.lua',
    'modules/callback/shared.lua',
    'modules/clothing/**/shared.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'core/defaults_server.lua',
    'modules/framework/**/server.lua',
    'modules/framework/server.lua',
    'modules/character/**/server.lua',
    'modules/character/server.lua',
    'modules/job/**/server.lua',
    'modules/job/server.lua',
    'modules/money/**/server.lua',
    'modules/inventory/**/server.lua',
    'modules/inventory/server.lua',
    'modules/vehicles/**/server.lua',
    'modules/vehicles/server.lua',
    'modules/notify/server.lua',
    'modules/entity/server.lua',
    'modules/banking/**/server.lua',
    'modules/phone/**/server.lua',
    'modules/clothing/**/server.lua',
    'modules/dispatch/**/server.lua',
    'modules/doorlock/**/server.lua',
    'modules/housing/**/server.lua',
    'modules/housing/server.lua',
    'modules/bossmenu/**/server.lua',
    'modules/skills/**/server.lua',
    'modules/vehicleOwnership/**/server.lua',
    'modules/death/**/server.lua',
    'modules/needs/**/server.lua',
    'modules/gang/**/server.lua',
    'modules/gang/server.lua',
    'modules/jobcount/server.lua',
    'modules/helptext/**/server.lua',
    'modules/helptext/server.lua',
    'lifecycle/**/server.lua',
    'core/loader_server.lua',
}

client_scripts {
    'core/defaults_client.lua',
    'modules/framework/**/client.lua',
    'modules/character/**/client.lua',
    'modules/job/**/client.lua',
    'modules/inventory/**/client.lua',
    'modules/notify/**/client.lua',
    'modules/notify/relay_client.lua',
    'modules/helptext/**/client.lua',
    'modules/target/**/client.lua',
    'modules/progressbar/**/client.lua',
    'modules/vehiclekey/**/client.lua',
    'modules/vehiclekey/client.lua',
    'modules/fuel/**/client.lua',
    'modules/weather/**/client.lua',
    'modules/input/**/client.lua',
    'modules/menu/**/client.lua',
    'modules/menu/client.lua',
    'modules/radial/**/client.lua',
    'modules/zones/**/client.lua',
    'modules/entity/client.lua',
    'modules/phone/**/client.lua',
    'modules/clothing/**/client.lua',
    'modules/dispatch/**/client.lua',
    'modules/doorlock/**/client.lua',
    'modules/housing/**/client.lua',
    'modules/bossmenu/**/client.lua',
    'modules/skills/**/client.lua',
    'modules/death/**/client.lua',
    'modules/gang/**/client.lua',
    'modules/vehicles/**/client.lua',
    'lifecycle/**/client.lua',
    'core/loader_client.lua',
}

dependencies {
    '/server:6116',
    '/onesync',
    'ox_lib',
    'oxmysql',
}
