
GTowerServers = GTowerServers or {}
GTowerServers.DEBUG = false
GTowerServers.UpdateRate = 5.0
GTowerServers.UpdateTolerance = GTowerServers.UpdateRate * 8

GTowerServers.GamemodeNames = file.Find("gmodtower/gamemode/multiserver/gamemodes/*.lua", "LUA") 
GTowerServers.Gamemodes = {}
for _, v in pairs( GTowerServers.GamemodeNames ) do
	GMode = {}
	include( "gamemodes/" .. v )
	
	GTowerServers.Gamemodes[ string.lower( string.Replace( v, ".lua", "" ) ) ] = GMode
	
	if SERVER then
		AddCSLuaFile( "gamemodes/" .. v )
	end
end
GMode = nil

function GTowerServers:Gamemode()
	return string.lower( string.Replace( GAMEMODE.Folder, "gamemodes/", "" ) )
end

function GTowerServers:GetGamemode( gm )
	return self.Gamemodes[ gm ]
end

function GTowerServers:Self()
	return self:GetGamemode( self:Gamemode() )
end 