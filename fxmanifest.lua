fx_version 'cerulean'
game 'gta5'

name 'cx-blueprints'
description 'A lightweight blueprint progression system designed to plug directly into oxinventory crafting.'
author 'Cxsper'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}
