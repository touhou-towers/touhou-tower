AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

include("shared.lua")

//local umsg, math, ents, timer, table = umsg, math, ents, timer, table
//local hook, util = hook, util
//local Msg = Msg
//local Vector = Vector
local hook, string = hook, string
local umsg = umsg
local player = player
local table = table
local timer = timer
local ents  = ents
local pairs = pairs
local IsValid = IsValid
local VectorRand = VectorRand
local Vector = Vector
local SafeCall = SafeCall
local _G = _G
local print = print
local CurTime = CurTime
local GTowerLocation = GTowerLocation

module("minigames.chainsaw" )

PlayerSpawnOnLobby = {}
MoneyPerKill = 3
TotalMoney = 0

function GiveWeapon( ply )
	
	if !ply:HasWeapon( WeaponName ) then
		ply.CanPickupWeapons = true
		ply:Give( WeaponName )
		ply:SelectWeapon( WeaponName )
		ply.CanPickupWeapons = false
	end
	
	ply:GodDisable()
	
end

function CheckGiveWeapon( ply, loc )
	
	if loc == MinigameLocation  then
		GiveWeapon( ply )
	else
		RemoveWeapon( ply )	
	end
	
end

function CheckRemoveBall( ply )

	if GTowerLocation:GetPlyLocation( ply ) == MinigameLocation then 


		if IsValid( ply.BallRaceBall ) then
	
			ply.BallRaceBall:Remove()
			ply.BallRaceBall = nil
		
		end

	end

end

function RemoveWeapon( ply )
	--if ply:HasWeapon(WeaponName) && ply:GetSetting( "GTAllowWeapons" ) == false && !ply:IsAdmin() then
	if ply:HasWeapon(WeaponName) then
		ply:StripWeapons()
	end
	
	ply:ResetGod()
end

function playerDies( ply, inflictor, killer )
	
	if GTowerLocation:GetPlyLocation( ply )  == MinigameLocation then
		table.insert( PlayerSpawnOnLobby, ply )
		
		//print( ply, inflictor, killer )
		
		if killer != ply && IsValid( killer ) &&  killer:IsPlayer() then
			killer:AddMoney( MoneyPerKill )
			TotalMoney = TotalMoney + MoneyPerKill
		end
		
	end

end

function PlayerInitialSpawn( ply )
	if !IsValid( FlyingText ) then
		return
	end

	for k, v in pairs( PlayerSpawnOnLobby ) do
		if v == ply then
			table.remove( PlayerSpawnOnLobby, k )
			return FlyingText
		end	
	end
end

function PlayerSpawn( ply )
	
	local Pos = GTowerLocation:GetPlyLocation( ply )
	
	if Pos == MinigameLocation then
		
		ply:SetVelocity( VectorRand() * 800 )
		ply.DisableCollision = CurTime() + 3.0 
		GiveWeapon( ply )
		
	end
	
end

function GetLocation()
	return MinigameLocation
end

function SendStartMessage( rp )
	umsg.Start("chainsaw", rp )
		umsg.Char( 0 )
		umsg.Char( GetLocation() )
	umsg.End()
end

function PlayerConnected( ply )
	SendStartMessage( ply )
end

local function GetSpawnPos( flags )
	if string.find( flags, "a" ) then
		return Vector( 2910.156250, 2596.843750, 60)
	end
	return Vector(938.531250, 1505.062500, 409.437500)
end

function PlayerDissalowResize( ply )
	if !ply:IsAdmin() then
		return false
	end
end

function Start( flags )

	hook.Add("Location", "ChainsawLocation", CheckGiveWeapon )
	//hook.Add("ShouldCollide", "LobbyColide", ShouldCollide )
	hook.Add( "PlayerDeath", "ChainSawCheckDeath", playerDies )
	hook.Add("PlayerSelectSpawn", "ChainSawPlayerSpawn", PlayerInitialSpawn )
	hook.Add("PlayerInitialSpawn", "ChainsawSendNW", PlayerConnected )
	hook.Add("PlayerSpawn", "ChainsawPlayerSpawn", PlayerSpawn )
	hook.Add("PlayerResize", "DoNotAllowResize", PlayerDissalowResize )
	hook.Add("PlayerThink", "ChainsawCheckRemoveBall", CheckRemoveBall )
	
	for _, v in pairs( player.GetAll() ) do
		SafeCall( CheckGiveWeapon, v, GTowerLocation:GetPlyLocation( v ) )
	end
	
	if !IsValid( FlyingText ) then
		FlyingText = ents.Create("gmt_skymsg")
		FlyingText:KeyValue( "text", "Chainsaw Battle!" )
		FlyingText:Spawn()
	end
	
	FlyingText:SetPos( GetSpawnPos( flags ) )
	
	SendStartMessage( nil )
	MinigameLocation = GetLocation()
	TotalMoney = 0
	
end

function End()
	
	hook.Remove("Location", "ChainsawLocation" )
	//hook.Remove("ShouldCollide", "LobbyColide" )
	hook.Remove( "PlayerDeath", "ChainSawCheckDeath" )
	hook.Remove("PlayerSelectSpawn", "ChainSawPlayerSpawn" )
	hook.Remove("PlayerInitialSpawn", "ChainsawSendNW" )
	hook.Remove("PlayerSpawn", "ChainsawPlayerSpawn" )
	hook.Remove("PlayerResize", "DoNotAllowResize")
	hook.Remove("PlayerThink", "ChainsawCheckRemoveBall" )
	
	for _, v in pairs( player.GetAll() ) do
		SafeCall( RemoveWeapon, v )
	end
	
	for _, v in pairs( ents.FindByClass(WeaponName) ) do
		v:Remove()
	end
	
	umsg.Start("chainsaw")
		umsg.Char( 1 )
		umsg.Long( TotalMoney )
	umsg.End()
	
	if IsValid( FlyingText ) then
		FlyingText:Remove()
		FlyingText = nil
	end
	
	
	
end