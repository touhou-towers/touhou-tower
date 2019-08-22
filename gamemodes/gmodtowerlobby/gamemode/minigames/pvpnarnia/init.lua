AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

include("shared.lua")

local SnowSpawnPoints = {
	{Vector(-4850.8125,-8231.9375,409.15625), Angle(0,187.40008544922,0)},
	{Vector(-5493.375,-8315.40625,400.5625), Angle(0,187.40008544922,0)},
	{Vector(-6199.375,-8407.125,391.125), Angle(0,187.40008544922,0)},
	{Vector(-6919.9375,-8438,378.78125), Angle(0,213.36024475098,0)},
	{Vector(-7416.375,-9151.625,355.875), Angle(0,242.62026977539,0)},
	{Vector(-8083.84375,-9914.59375,383.15625), Angle(0,230.740234375,0)},
	{Vector(-7984.25,-10521.34375,313.28125), Angle(0,306.20031738281,0)},
	{Vector(-8170.5625,-11329.21875,441.46875), Angle(0,343.16033935547,0)},
	{Vector(-7441.5,-11350.0625,361.1875), Angle(0,15.500329971313,0)},
	{Vector(-7163.28125,-10943.96875,368.15625), Angle(0,40.360374450684,0)},
	{Vector(-6637.0625,-11160.34375,344.4375), Angle(0,321.38037109375,0)},
	{Vector(-5935.28125,-11744.34375,375.34375), Angle(0,10.000370025635,0)},
	{Vector(-5399.28125,-11367.46875,445.1875), Angle(0,60.820415496826,0)},
	{Vector(-5224.375,-10786.96875,483.6875), Angle(0,101.08046722412,0)},
	{Vector(-5435.15625,-10324.09375,465.375), Angle(0,104.60042572021,0)},
	{Vector(-5634.8125,-9571.0625,502.1875), Angle(0,106.36043548584,0)},
	{Vector(-6294.28125,-9199.625,505.15625), Angle(0,195.90051269531,0)},
	{Vector(-6458.96875,-10027.4375,509.03125), Angle(0,271.80059814453,0)},
	{Vector(-6724.875,-10618.09375,482.71875), Angle(0,218.78062438965,0)},
	{Vector(-6973.78125,-8964.21875,517.65625), Angle(0,26.940263748169,0)},
	{Vector(-4637.71875,-8633,548.75), Angle(0,214.9001159668,0)},
	{Vector(-4980.5,-9481.5625,241.53125), Angle(0,262.86019897461,0)},
	{Vector(-5016.65625,-10761.875,230.78125), Angle(0,267.70016479492,0)},
	{Vector(-5460.96875,-11543.84375,303.59375), Angle(0,168.91996765137,0)},
	{Vector(-6626.5625,-11304.90625,342.125), Angle(0,171.5599822998,0)},
	{Vector(-7135.40625,-10803.3125,376.25), Angle(0,132.61996459961,0)},
	{Vector(-8041,-10248.65625,336.03125), Angle(0,69.699897766113,0)},
	{Vector(-7406.1875,-9232.53125,421.5625), Angle(0,27.459844589233,0)},
	{Vector(-6076.3125,-8362.5,416.78125), Angle(0,3.2598395347595,0)},
	{Vector(-5316.53125,-9853.15625,402.65625), Angle(0,280.75979614258,0)},
	{Vector(-6155,-10332.53125,524.3125), Angle(0,136.43963623047,0)}
}

//local umsg, math, ents, timer, table = umsg, math, ents, timer, table
//local hook, util = hook, util
//local Msg = Msg
//local Vector = Vector
local GTowerLocation = GTowerLocation

module("minigames.pvpnarnia",package.seeall )


ActivePlayers = {}
SpawnPoints = {}
WeaponList = {}
BallEntity = nil
RandomWeapons = true

function CheckLocation( ply )

	if GTowerLocation:GetPlyLocation( ply ) != 51 then

		local Random = table.Random( SnowSpawnPoints )

		ply:SetPos( Random[1] )

	end

end

function GiveRandomWeapons( ply )

	local GivenWeapons = {"weapon_sword"}

	ply:Give("weapon_sword")

	for k, weplist in ipairs( WeaponList ) do
		if #weplist > 0 then

			local WeaponName = table.Random( weplist )
			ply:Give( WeaponName )
			table.insert( GivenWeapons, WeaponName )

		end
	end

	return GivenWeapons

end

function SpawnPlayer( ply )

	ply:GodDisable()

	ply.CanPickupWeapons = true
	local GivenWeapons

	if RandomWeapons == true then
		GivenWeapons = GiveRandomWeapons( ply )
	else
		GivenWeapons = PvpBattle:GiveWeapons( ply )
	end

	//Ammo
	ply:GiveAmmo( 54, "SMG1", true )
	ply:GiveAmmo( 1, "SMG1_Grenade", true )
	ply:GiveAmmo( 24, "357", true )
	ply:GiveAmmo( 28, "Pistol", true )
	ply:GiveAmmo( 18, "Buckshot", true )
	ply:GiveAmmo( 50, "AR2", true )
	ply:GiveAmmo( 12, "SniperRound", true )
	ply:GiveAmmo( 4, "RPG_Round", true )
	ply:GiveAmmo( 4, "slam", true )

	ply.CanPickupWeapons = false

	ply:SelectWeapon( table.Random( GivenWeapons ) )

	timer.Simple( 0.0, CheckLocation, ply )
end

function HookOnDeath( pl, inf, attacker )

	if IsValid( attacker ) && attacker:IsPlayer() && attacker != pl then
		attacker:AddMoney( 5 )
	end

end

function OnEntUse( ply, caller )
	if ply:IsPlayer() then
		GTowerModels.Set( ply, 1.0 )
		AddPlayer( ply )
		ply:Spawn()
	end
end

function AddPlayer( ply )

	table.insert( ActivePlayers, ply )

	umsg.Start("pvpnarnia", ply )
		umsg.Char( 0 )
	umsg.End()

	ply._DisabledJetpack = true

end

function HookPlayerSpawn( ply )
	if InGame( ply ) then
		SpawnPlayer( ply )
		return true
	end
end

function InGame( ply )
	return table.HasValue( ActivePlayers, ply )
end

function RemovePlayer( ply )

	for k, v in ipairs( ActivePlayers ) do
		if v == ply then
			table.remove( ActivePlayers, k )
		end
	end

	if IsValid( ply ) then
		umsg.Start("pvpnarnia", ply )
			umsg.Char( 1 )
		umsg.End()

		if ply:Alive() then
			ply:Kill()
		end

		ply._DisabledJetpack = nil
	end

end


function CheckNontheater( ply, loc )

	if InGame( ply ) && Location.IsTheater( loc ) then
		if ply:Alive() then
			ply:Kill()
		end
	end

end


function PlayerSelectSpawn( ply )

	if InGame( ply ) then
		local i
		for i=1, 5 do
			local random_entry = table.Random( SpawnPoints )

			if IsValid( random_entry ) then
				return random_entry
			end
		end
	end

end

function CleanSpawnPoints()
	for _, v in ipairs( SpawnPoints ) do
		SafeRemoveEntity( v )
	end
end

function HookDisableResize( ply, size )
	if InGame( ply ) then
		return false
	end
end

function WeaponOverride( ply )
	if InGame( ply ) then
		return true
	end
end

function ShouldCollide( ply1, ply2 )
	if InGame( ply1 ) && InGame( ply2 ) then
		return true
	end
end


function Start( flags )

	if !IsValid( BallEntity ) then
		BallEntity = ents.Create("gmt_minigame_entrance")
		BallEntity:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
		BallEntity:SetPos( Vector(928.023315, -672.636230, 64.031250) )
		BallEntity:Spawn()
		BallEntity:SetUse( OnEntUse )
	end

	CleanSpawnPoints()

	for _, v in pairs( SnowSpawnPoints ) do
		local Trace = util.QuickTrace(  v[1], Vector( 0, 0, -4096 ) )
		local Pos = Trace.HitPos + Vector(0,0,127)

		local ent = ents.Create("info_specialspawn")
		ent:SetPos( Pos )
		ent:Spawn()

		table.insert( SpawnPoints, ent )
	end

	WeaponList = {}

	for k, v in ipairs( PvpBattle.WeaponList ) do

		if !WeaponList[k] then
			WeaponList[k] = {}
		end

		for _, name in ipairs( v ) do

			local Item = GTowerStore:GetItemByName( name )
			local WeaponName = PvpBattle.WeaponsIds[ Item ]

			table.insert( WeaponList[k], WeaponName )

		end

	end

	PrintTable( WeaponList )


	hook.Add("PlayerSelectSpawn","PVPNarniaChoose", PlayerSelectSpawn )
	hook.Add("PlayerSpawn", "PVPNarniaSpawn", HookPlayerSpawn )
	hook.Add("PlayerDeath", "PVPNarniaDeath", HookOnDeath )
	hook.Add("PlayerResize", "DisableResizing", HookDisableResize )
	hook.Add("WeaponOverride", "DisableWeaponOverride", WeaponOverride )
	hook.Add("ShouldCollide", "EnableNarniaCollisions", ShouldCollide )

end

function End()

	hook.Remove("PlayerSpawn", "PVPNarniaSpawn" )
	hook.Remove("PlayerDeath", "PVPNarniaDeath" )
	hook.Remove("PlayerSelectSpawn","PVPNarniaChoose" )
	hook.Remove("PlayerResize", "DisableResizing")
	hook.Remove("WeaponOverride", "DisableWeaponOverride")
	hook.Remove("ShouldCollide", "EnableNarniaCollisions" )

	for _, ply in pairs( table.Copy( ActivePlayers ) ) do
		SafeCall( RemovePlayer, ply )
	end

	CleanSpawnPoints()

	if IsValid( BallEntity ) then
		BallEntity:Remove()
	end

end

concommand.Add("gmt_pvpnarnialeave", function( ply, cmd, args )

	if InGame( ply ) then
		RemovePlayer( ply )
	end

end )
