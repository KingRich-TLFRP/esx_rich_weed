resource_manifest_version '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

server_scripts {

  '@mysql-async/lib/MySQL.lua',
  'server/weedz_sv.lua',
  'config.lua'

}

client_scripts {

  '@NativeUI/NativeUI.lua',
  'client/MenuExample.lua',
  'config.lua',
  'client/weedz_cl.lua'

}
