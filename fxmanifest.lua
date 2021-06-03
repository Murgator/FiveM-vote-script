fx_version 'adamant'
games { 'gta5' }

author 'Murgator'
description 'Trackyserver vote script'
version '1.1.2'

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
	'@async/async.lua',
	'@mysql-async/lib/MySQL.lua',
    "server/server.lua"
}

dependencies {
	'es_extended',
	'async'
}

client_scripts {
    "client/language.lua"
}