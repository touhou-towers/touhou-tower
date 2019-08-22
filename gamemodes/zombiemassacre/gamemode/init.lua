AddCSLuaFile( "cl_classchooser.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_hudchat.lua" )
AddCSLuaFile( "cl_hudmessage.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_input.lua" )
AddCSLuaFile( "cl_math.lua")
AddCSLuaFile( "cl_math_color.lua")
AddCSLuaFile( "cl_modelpanel.lua" )
AddCSLuaFile( "cl_music.lua" )
AddCSLuaFile( "cl_radar.lua" )
AddCSLuaFile( "cl_util.lua" )
AddCSLuaFile( "includes/modules/GTowerModels.lua" )
AddCSLuaFile( "postprocess/init.lua" )
AddCSLuaFile( "sh_classmanager.lua" )
AddCSLuaFile( "sh_movement.lua" )
AddCSLuaFile( "sh_player_meta.lua" )
AddCSLuaFile( "shared.lua" )

AddCSLuaFile("gmt/cl_scoreboard.lua")

include( "dropmanager/init.lua" )

include("multiserver.lua")

include("sv_helicopters.lua")
include( "postprocess/init.lua" )
include( "round.lua" )
include( "sh_classmanager.lua" )
include( "sh_movement.lua" )
include( "sh_player_meta.lua" )
include( "shared.lua" )

util.AddNetworkString( "gmt_heli_fly" )

GM.NPCLimit = 120

CreateConVar("gmt_srvid", 8 )

function GM:Intialize()
	RegisterNWGlobal()
	RunConsoleCommand( "sv_playerpickupallowed", 0 )
end

function GM:IsSpawnpointSuitable( ply, spawnpointent, bMakeSuitable )
	return true
end

function GM:PlayerDeathThink()
	return false
end

function GM:DoPlayerDeath( victim )
	local grave = ents.Create("zm_player_gravestone")
	grave:SetPos(victim:GetPos())
	grave:SetAngles(victim:GetAngles())
	grave:Spawn()
	grave:SetOwner(victim)
end

hook.Add("EntityTakeDamage","WeaponAchiCheck",function( target, dmginfo )
	local amount = dmginfo:GetDamage()
	local ply = dmginfo:GetAttacker()
	if !IsValid(ply) then return end
	if target:IsNPC() && target:Health() < amount then
		local wepclass = ply:GetActiveWeapon():GetClass()

		if wepclass == "weapon_zm_special_focus" then
			ply:AddAchivement( ACHIVEMENTS.ZMFOCUS, 1 )
		elseif wepclass == "weapon_zm_ghostbuster" then
			ply:AddAchivement( ACHIVEMENTS.ZMGHOSTBUSTER, 1 )
		elseif wepclass == "weapon_zm_nesguitar" then
			ply:AddAchivement( ACHIVEMENTS.ZMNESGUITAR, 1 )
		end

		local melee = { "weapon_zm_nesguitar", "weapon_zm_baseballbat", "weapon_zm_chainsaw", "weapon_zm_katana", "weapon_zm_medevilsword", "weapon_zm_melee_survivor", "weapon_zm_sledgehammer" }

		if table.HasValue( melee, wepclass ) then
			ply:AddAchivement( ACHIVEMENTS.ZMMELEE, 1 )
		end

		if target:GetClass() == "zm_npc_dog" then
			ply:AddAchivement( ACHIVEMENTS.ZMDOGKILL, 1 )
		end

		if target:GetClass() == "zm_npc_zombie" then
			ply:AddAchivement( ACHIVEMENTS.ZMMASSACRE, 1 )
		else
			ply:AddAchivement( ACHIVEMENTS.ZMMUTANT, 1 )
		end

	end
end)

hook.Add( "PlayerInitialSpawn", "ResetOnEmptyServer", function( ply )

	if #player.GetAll() == 0 then
		GAMEMODE:SetState( STATE_NOPLAY )
	elseif !ply:IsBot() && #player.GetAll() >= 1 then

		PlayerNWSetup(ply)

		-- This is a one time deal, or it can be abused to make a infinite game by reconnecting
		hook.Remove("PlayerInitialSpawn", "ResetOnEmptyServer")

		GAMEMODE:SetState( STATE_WAITING )
		SetGlobalInt( "ZMDayTime", CurTime() + 45 )
		SetGlobalInt( "Round", 1 )
	end

	umsg.Start( "ZMPlayMusic", ply )
		umsg.Char(1)
	umsg.End()

end )

hook.Add( "PlayerInitialSpawn", "zm_defaultclass", function( ply )

			--  If the players joins outside of the upgrading state, make them survivor.
			if GAMEMODE:GetState() == STATE_UPGRADING then return end

			local getclass = classmanager.Get( "survivor" )

			if getclass then
				ply.Class = getclass
				ply.Class:Setup( ply )
				ply:SetNWString( "ClassName", ply.Class.Name )
				ply:Give( "weapon_zm_handgun" )
			end

end )

hook.Add( "PlayerSpawn", "Weapon_Give", function( ply )

	if GAMEMODE.GameStarted == true then
		ply:Give("weapon_zm_handgun")
	end

	--  Set player model
	hook.Call( "PlayerSetModel", GAMEMODE, ply )

	ply:SetNoCollideWithTeammates( true )

	ply:ConCommand( 'zm_comboclear' )

	ply:SetPos( ply:GetPos() + Vector(0,0,35) )

end )


function GM:InitPostEntity()

	self.PlayerSpawns = ents.FindByClass( "info_player_start" )

	-- This camera is created for a number of reasons.
	-- I will be using this to do cinematics later.
	local cam = ents.Create( "prop_physics" )

	cam:SetModel( "models/player.mdl" )
	cam:SetPos( self.PlayerSpawns[1]:GetPos() )
	cam:SetColor( 255, 255, 255, 0 )
	cam:SetAngles( Angle( 65, 0, 0 ) )
	cam:Spawn()
	cam:Activate()
	cam:SetSolid( SOLID_NONE )
	cam:SetMoveType( MOVETYPE_NONE )
	cam:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

	self.Camera = cam

	--  setup our drop system
	DropManager.Initialize()

end

function GM:PlayerShouldTakeDamage( ply, attacker )
	if ply:IsPlayer() && attacker:IsPlayer() then
		return false
	end

	if self:GetState() == STATE_WAITING || self:GetState() == STATE_UPGRADING then
		return false
	end

	return true
end

function GM:EntityTakeDamage( target, dmginfo )

	local amount = dmginfo:GetDamage()
	local ply = dmginfo:GetAttacker()

	--if amount < 1 then return end

	if target:IsPlayer() && dmginfo:GetInflictor():IsPlayer() then
		return false
	end

	if string.StartWith( target:GetClass(), "zm_npc_boss" ) then
		SetGlobalInt( "BossHealth", target:Health() )
	end

	if target:IsNPC() && target:Health() < amount then
		umsg.Start( "HUDNotes" )
			umsg.Char(4)
			umsg.Short( 0 )
			umsg.Short(target:EntIndex())
		umsg.End()
	elseif target:IsNPC() && ( !self.LastDamageNote || self.LastDamageNote < CurTime() ) then
		umsg.Start( "HUDNotes" )
			umsg.Char(1)
			umsg.Short( math.Round( dmginfo:GetDamage() ) )
			umsg.Short(target:EntIndex())
		umsg.End()

		self.LastDamageNote = CurTime() + .15 -- let's not have so many damage notes going on.
	end

	if ply:GetNWInt( "Combo" ) > 4 then
		ply:SetNWBool( "IsPowerCombo", true )
	end

end

GM.RandoInfected = {
	"zm_npc_dog",
	"zm_npc_mutant",
	--"zm_npc_spider",
}

-- This is a temp function for testing ONLY.
-- doesnt seem to be testing only
function GM:SpawnZombies()

	self.ZombieSpawns = ents.FindByClass( "info_zombie_spawn" )

	if GetGlobalBool( "ZMDayOver",false ) then return end

	local curzomb = #ents.FindByClass( "zm_npc_*" )
	local entclass = "zm_npc_zombie"

	if ( math.Rand( 0, 1 ) <= 0.05 && GetGlobalInt( "Round" ) >= 2 ) then
		entclass = table.Random(self.RandoInfected)
	end

	if curzomb < self.NPCLimit then
		local zmSpawns = math.min(player.GetCount() + GetGlobalInt('Round'), self.NPCLimit - curzomb)
		for _ = 1, zmSpawns do
			local zom = ents.Create( entclass )
			zom:SetCustomCollisionCheck( true )
			zom:SetPos( self.ZombieSpawns[math.random( 1, #self.ZombieSpawns )]:GetPos() + Vector(0,0,25) )
			zom:SetAngles( Angle( 0, 0, 0 ) )
			zom:Spawn()

			local eff = EffectData()
			eff:SetEntity( zom )
			eff:SetOrigin( zom:GetPos() )
			eff:SetNormal( zom:GetUp() )
			util.Effect( "zombspawn", eff, true, true )
		end
	end

	-- not including player count
	-- original goes between lower bounds of (2, 1) and upper of (3, 2)
	-- delay is in seconds so let's just put it at 1 and spawn zombies depending on the players
	-- theoretically I should be able to just put self:SpawnZombies instead of the function?
	-- well binding problems and such and i dont want to risk it for now
	timer.Simple(1, function() self:SpawnZombies() end )

end

function RegisterNWGlobal()
	SetGlobalInt( "Round", 0 )
	SetGlobalInt( "Difficulty", 1 )
	SetGlobalEntity( "Helicopter", Entity(0) )
	SetGlobalEntity( "Boss", Entity(0) )
	SetGlobalString( "BossName", "" )
	SetGlobalInt( "BossHealth", 0 )
	SetGlobalInt( "BossMaxHealth", 0 )
end

function PlayerNWSetup(ply)
	ply:SetNWInt( "Points", 0 )
	ply:SetNWInt( "Combo", 0 )
	ply:SetNWInt( "Lives", 2 )
	ply:SetNWBool( "IsPowerCombo", false )
	ply:SetNWBool( "IsPoweredUp", false )
	ply:SetNWBool( "IsSpawning", false )
	ply:SetNWBool( "IsFocused", false )
	ply:SetNWString( "ClassName", string.lower(classmanager.GetRandom().Name) )
	ply:SetNWVector( "CursorPos", Vector( 0, 0, 0 ) )
	ply:SetNWBool( "Upgraded", false )
	ply:SetNWInt( "LastItem", 0 )
	ply:SetNWString( "BackWeaponClass", "" )
	ply:SetNWBool( "LockedWeapons", false )
	ply:SetNWBool( "FlameOn", false )
	ply:SetNWEntity( "Ghost", nil )
end

hook.Add( "AllowSpecialAdmin", "DisallowGodmode", function() return false end )

hook.Add( "OnNPCKilled", "NPCKillNote", function( npc, attacker, inflictor )
	umsg.Start( "HUDNotes" )
		umsg.Char(4)
		umsg.Short( 0 )
		umsg.Short(npc:EntIndex())
	umsg.End()
end )
hook.Add( "PlayerDeath", "DeductLives", function(victim, inflictor, attacker)
	umsg.Start( "HUDMessage" )
		umsg.Char(7)
		umsg.Char(10)
		umsg.Entity(victim)
		umsg.Entity(nil)

		umsg.Short(255)
		umsg.Short(255)
		umsg.Short(255)
		umsg.Short(255)
	umsg.End()

	if victim:GetNWInt("Lives") > 0 then
		victim:SetNWInt( "Lives", victim:GetNWInt("Lives") - 1 )
	end
end )

concommand.Add( "zm_comboclear", function( ply )
	ply:SetNWInt( "Combo", 0 )
	ply:SetNWBool( "IsPowerCombo", false )
end )

concommand.Add("zm_cursorupdate",function( ply, cmd, args )

	if IsValid(ply) then

		local x = -args[1]
		local y = -args[2]

		ply:SetNWVector("CursorPos",Vector(x,y,0))
	end

end)

concommand.Add( "zm_upgradeunfinish", function( ply ) ply:SetNWBool( "Upgraded", false ) end )
concommand.Add( "zm_upgradefinish", function( ply ) ply:SetNWBool( "Upgraded", true ) end )

hook.Add( "PlayerDisconnected", "NoPlayerCheck", function(ply)

	if ply:IsBot() then return end

	timer.Simple(0.2,function()
		if player.GetCount() == 0 then GAMEMODE:EndServer() end
	end)
end)

hook.Add("GTowerMsg","GamemodeMessage",function()
	-- Join panel communication

	-- General states
	if player.GetCount() < 1 then
		return "#nogame"
	elseif GAMEMODE.BossRound then
		return "#boss"
	elseif GAMEMODE:GetState() == STATE_UPGRADING then
		return "#before"
	end

	-- Complex states
	-- TIMELEFT |||| CURROUND / MAXROUNDS

	return GAMEMODE:GetTimeLeft() .. "||||" .. GetGlobalInt("Round") .. "/" .. "5"

end)
