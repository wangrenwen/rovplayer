# rovplayer
a Media Player used for M3U8 File, with the OSMF ,and Denivip's HLS plugin.
1. dev with FlashBuilder 4.7.
2. compilier options:
  //ui
  default-background-color=0x111111
  -default-size 1920 1080
  
  //some config param
  -define=CONFIG::release,false
  -compiler.debug=true
  -define CONFIG::FLASH_10_1 true
  -define CONFIG::LOGGING true
  -define CONFIG::MOCK false
  -define CONFIG::PLATFORM false
  //this is used for watching dowloadspeed num.
  -define CONFIG::RENWEN true
  
3. the MonsterDebugger is tools for trace info. its a AIR Destkop application.
