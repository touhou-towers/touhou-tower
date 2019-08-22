AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

include( "multiserver.lua" )

spawning = 0

/* Server Side Files */
for k, v in pairs( file.Find( GM.Folder:Replace( "gamemodes/", "") .. "/gamemode/sv_*.lua", "LUA" ) ) do
	include( v )
end

/* Client Side Files */
for k, v in pairs( file.Find( GM.Folder:Replace( "gamemodes/", "") .. "/gamemode/cl_*.lua", "LUA" ) ) do
	AddCSLuaFile( v )
end

/* Shared Files */
for k, v in pairs( file.Find( GM.Folder:Replace( "gamemodes/", "") .. "/gamemode/sh_*.lua", "LUA" ) ) do
	AddCSLuaFile( v )
	include( v )
end

/* Scoreboard Files */
for k, v in pairs( file.Find( GM.Folder:Replace( "gamemodes/", "") .. "/gamemode/scoreboard/*.lua", "LUA" ) ) do
	AddCSLuaFile( "scoreboard/" .. v )
end

CreateConVar("gmt_srvid", 7 )

function GM:Initialize()
	RegisterNWTableG()
	self:SetGameState( STATUS_WAITING )
	
	//timer.Simple( .1, GAMEMODE:CacheStuff() ) //Precaching stuff
	timer.Simple(.1, function() GAMEMODE:CacheStuff() end)
	
	//self:SetState( 1 ) /* multiserver state */
	
end

function GM:SetMusic( ply, idx, teamid )

	umsg.Start( "UC_PlayMusic", ply )
		umsg.Char( idx )
		if teamid then
			umsg.Char( teamid )
		end
	umsg.End()

end

function GM:HUDMessage( ply, index, time, ent, ent2, color )
	
	umsg.Start( "HudMsg", ply )
		umsg.Char( index )
		umsg.Char( time )
		if ( IsValid( ent ) ) then
			umsg.Entity( ent )
		end
		
		if ( IsValid( ent2 ) ) then
			umsg.Entity( ent2 )
		end
		
		if color != nil then
			umsg.Short( color.r )
			umsg.Short( color.g )
			umsg.Short( color.b )
			umsg.Short( color.a )
		end
		
	umsg.End()
	
end

function GM:SendKillNotice( str, ent1, ent2 )
	
	umsg.Start( "KillNotice" )
		umsg.String( str )
		umsg.Entity( ent1 )
		if ent2 && IsValid( ent2 ) then
			umsg.Entity( ent2 )
		end
	umsg.End()
	
end

function GM:DoKillNotice( ply )

	if ply.IsChimera then

		if ply.Pressed && IsValid( ply.Presser ) then
			GAMEMODE:SendKillNotice( "press", ply, ply.Presser )
			ply.Pressed = false
			ply.Presser = nil
		elseif ply.SaturnKill && IsValid( ply.SaturnThrower ) then
			GAMEMODE:SendKillNotice( "saturn", ply, ply.SaturnThrower )
			ply.SaturnKill = false
			ply.SaturnThrower = nil
		else
			GAMEMODE:SendKillNotice( "skull", ply )
		end

	else

		if ply.Squished then
			ply.Squished = false
			GAMEMODE:SendKillNotice( "pop", ply, GAMEMODE:GetUC())
			return
		end

		if ply.Bit then
			ply.Bit = false
			GAMEMODE:SendKillNotice( "bite", ply, GAMEMODE:GetUC())
			return
		end

		if ply.Suicide then
			ply.Suicide = false
			GAMEMODE:SendKillNotice( "suicide", ply )
			return
		end

		GAMEMODE:SendKillNotice( "skull", ply )

	end
end