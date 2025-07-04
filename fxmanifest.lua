fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_scripts { 
	'config.lua',
	'@ox_lib/init.lua',
}

client_scripts {	
	'@es_extended/imports.lua',
	'client/*.lua'
}

server_scripts {
	'@es_extended/imports.lua',
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}

escrow_ignore {
	'config.lua'
}
  
dependency '/assetpacks'