fx_version 'cerulean'
game 'gta5'

version '1.0.0'
author 'AiReiKe'
description 'Eric Advanced Money Wash(QB Version)'
lua54 'yes'

shared_scripts {
    '@qb-core/shared/locale.lua',
    '@ox_lib/init.lua',
    'locales/*.lua',
    'config.lua'
}

server_scripts {
    'server/*.lua'
}

client_script 'client.lua'

dependencies {
    'qb-core',
    'qb-input'
}