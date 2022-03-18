fx_version 'adamant'
games { 'gta5' }

author 'Murgator'
description 'Trackyserver vote script'
version '1.1.5'

files {
    "locales/american.json",
    "locales/french.json",
    "locales/german.json",
    "locales/italian.json",
    "locales/spanish.json",
    "locales/portuguese.json",
    "locales/polish.json",
    "locales/russian.json",
    "locales/korean.json",
    "locales/chinese.json",
    "locales/japanese.json",
    "locales/mexican.json"
}

server_scripts {
    "config.lua",
    "server/server.lua"
}

client_scripts {
    "client/language.lua"
}
