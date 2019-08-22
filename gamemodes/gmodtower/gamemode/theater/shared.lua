
include( 'sh_load.lua' )

include( 'player_class/player_lobby.lua' )
include( 'translations.lua' )

Loader.Load( "extensions" )
Loader.Load( "modules" )

-- Load Map configuration file
local strMap = GM.FolderName .. "/gamemode/theater/maps/" .. game.GetMap() .. ".lua"
if file.Exists( strMap, "LUA" ) then
	if SERVER then
		AddCSLuaFile( strMap )
	end
	include( strMap )
end 