AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

include("shared.lua")

local SnowSpawnPoints = {
	{Vector(-4850.8125,-8231.9375,409.15625), Angle(0.76002258062363,187.40008544922,0)},
	{Vector(-5493.375,-8315.40625,400.5625), Angle(0.76002258062363,187.40008544922,0)},
	{Vector(-6199.375,-8407.125,391.125), Angle(0.76002258062363,187.40008544922,0)},
	{Vector(-6919.9375,-8438,378.78125), Angle(0.76002240180969,213.36024475098,0)},
	{Vector(-7416.375,-9151.625,355.875), Angle(2.3000223636627,242.62026977539,0)},
	{Vector(-8083.84375,-9914.59375,383.15625), Angle(356.14001464844,230.740234375,0)},
	{Vector(-7984.25,-10521.34375,313.28125), Angle(4.9400234222412,306.20031738281,0)},
	{Vector(-8170.5625,-11329.21875,441.46875), Angle(2.9600217342377,343.16033935547,0)},
	{Vector(-7441.5,-11350.0625,361.1875), Angle(6.7000217437744,15.500329971313,0)},
	{Vector(-7163.28125,-10943.96875,368.15625), Angle(357.02001953125,40.360374450684,0)},
	{Vector(-6637.0625,-11160.34375,344.4375), Angle(0.98002123832703,321.38037109375,0)},
	{Vector(-5935.28125,-11744.34375,375.34375), Angle(356.14001464844,10.000370025635,0)},
	{Vector(-5399.28125,-11367.46875,445.1875), Angle(356.14001464844,60.820415496826,0)},
	{Vector(-5224.375,-10786.96875,483.6875), Angle(357.90002441406,101.08046722412,0)},
	{Vector(-5435.15625,-10324.09375,465.375), Angle(357.02001953125,104.60042572021,0)},
	{Vector(-5634.8125,-9571.0625,502.1875), Angle(358.12002563477,106.36043548584,0)},
	{Vector(-6294.28125,-9199.625,505.15625), Angle(358.78002929688,195.90051269531,0)},
	{Vector(-6458.96875,-10027.4375,509.03125), Angle(359.66000366211,271.80059814453,0)},
	{Vector(-6724.875,-10618.09375,482.71875), Angle(4.2800178527832,218.78062438965,0)},
	{Vector(-6973.78125,-8964.21875,517.65625), Angle(358.12002563477,26.940263748169,0)},
	{Vector(-4637.71875,-8633,548.75), Angle(0.7600125670433,214.9001159668,0)},
	{Vector(-4980.5,-9481.5625,241.53125), Angle(1.2000108957291,262.86019897461,0)},
	{Vector(-5016.65625,-10761.875,230.78125), Angle(358.7799987793,267.70016479492,0)},
	{Vector(-5460.96875,-11543.84375,303.59375), Angle(352.61999511719,168.91996765137,0)},
	{Vector(-6626.5625,-11304.90625,342.125), Angle(4.0600056648254,171.5599822998,0)},
	{Vector(-7135.40625,-10803.3125,376.25), Angle(358.33999633789,132.61996459961,0)},
	{Vector(-8041,-10248.65625,336.03125), Angle(352.17999267578,69.699897766113,0)},
	{Vector(-7406.1875,-9232.53125,421.5625), Angle(3.1800057888031,27.459844589233,0)},
	{Vector(-6076.3125,-8362.5,416.78125), Angle(359.44000244141,3.2598395347595,0)},
	{Vector(-5316.53125,-9853.15625,402.65625), Angle(359.66000366211,280.75979614258,0)},
	{Vector(-6155,-10332.53125,524.3125), Angle(352.83999633789,136.43963623047,0)}
}

//local umsg, math, ents, timer, table = umsg, math, ents, timer, table
//local hook, util = hook, util
//local Msg = Msg
//local Vector = Vector

module("minigames.plane",package.seeall )

ActiveSpawnPoints = SnowSpawnPoints
ActivePlayers = {}
BallEntity = nil
TrailEnabled = true
TotalMoneyEarned = 0

sound.Add( {
	name = "plane_engine",
	volume = 0.8,
	level = 90,
	pitch = { 95, 110 },
	sound = "vehicles/airboat/fan_motor_fullthrottle_loop1.wav"
} )

function GetPlaneVel( ply )
	return ply._PlaneVelocity or 100
end

function SetPlaneVel( ply, vel, ang  )
	ply._PlaneVelocity = vel

	if !ply._LastPlaneSend || CurTime() > ply._LastPlaneSend then
		umsg.Start("plane", ply )
			umsg.Char( 2 )
			umsg.Float( vel )

			if ang then
				umsg.Bool( true)
				umsg.Angle( ang )
			else
				umsg.Bool( false )
			end

		umsg.End()

		ply._LastPlaneSend = CurTime() + 1.0
	end
end

function SpawnPlayer( ply )

	ply:DrawViewModel( false )
	//ply:SetModel("models/props_c17/doll01.mdl")

	local RandomPos = table.Random(SnowSpawnPoints)

	ply:SetPos( RandomPos[1] )
	ply:SetAllowFullRotation( true )

	if TrailEnabled then
		ply.m_entTrail = util.SpriteTrail( ply, 0, Color( 180, 180, 190, 255 ), true, 0, 16, 10, 0.01, "trails/smoke.vmt" )
		ply.m_entTrail:SetParent( ply )
	end

	ply:SetHull( Vector( -16, -16, -16 ), Vector( 16, 16, 16 ) )
	ply:SetViewOffset( Vector( 0, 0, 0 ) )
	ply:SetMoveType( MOVETYPE_NOCLIP )

	ply:SetPos( ply:GetPos() )
	ply:SetAngles( Angle( 0, 0, 0 ) )

	ply.plane = ents.Create( "plane" )
		ply.plane:SetPos( ply:GetPos() )
		ply.plane:SetParent( ply )
		ply.plane:SetOwner( ply )
		ply.plane:Spawn()
		ply.plane:EmitSound("plane_engine")

	SetPlaneVel( ply, 100, RandomPos[2] )
	ply:GodDisable()

	if !ply:HasWeapon("weapon_planegun") then
		ply.CanPickupWeapons = true
		ply:Give( "weapon_planegun" )
		ply.CanPickupWeapons = false
	end

	ply:SetAnimation( ply:LookupSequence( "drive_jeep" ) )
end


function ExplodePlaneParts( pl )

	local explosion = ents.Create( "env_explosion" ) // Creating our explosion
	explosion:SetKeyValue( "spawnflags", 144 ) //Setting the key values of the explosion
	explosion:SetKeyValue( "iMagnitude", 0 ) // Setting the damage done by the explosion
	explosion:SetKeyValue( "iRadiusOverride", 256 ) // Setting the radius of the explosion
	explosion:SetPos(pl:GetPos()) // Placing the explosion where we are
	explosion:Spawn( ) // Spawning it
	explosion:Fire("explode","",0)

end


function HookOnDeath( pl, inf, attacker )

	if ( IsValid( pl.m_entTrail ) ) then
		pl.m_entTrail:SetAttachment( nil )
		local trail = pl.m_entTrail
		timer.Simple( 30, function() if ( IsValid( trail ) ) then trail:Remove() end end )
	end

	if IsValid( pl.plane ) then
		ExplodePlaneParts( pl )
		pl.plane:StopSound("plane_engine")
		pl.plane:Remove()
	end

	if InGame( pl ) && InGame( attacker ) && IsValid( attacker ) && attacker:IsPlayer() && attacker != pl then
		attacker:AddMoney( 5 )
		attacker:AddAchivement( ACHIVEMENTS.MGREDBARON, 1 )
		attacker._PlaneKills = attacker._PlaneKills + 1
		TotalMoneyEarned = TotalMoneyEarned + 5
	end

end

function DoExplosion( pl )

	/*
	if ( !IsValid( pl ) ) then return end

	util.BlastDamage( pl, pl, pl:GetPos(), 300, 200 )

	local effectdata = EffectData()
		effectdata:SetOrigin( pl:GetPos() )
 	util.Effect( "Explosion", effectdata, true, true )
	*/
end

function OnEntUse( ply, caller )
	if ply:IsPlayer() then
		AddPlayer( ply )
		ply:Spawn()

		if IsValid( ply.BallRaceBall ) then

			ply.BallRaceBall:Remove()
			ply.BallRaceBall = nil

		end

	end
end

function AddPlayer( ply )

	table.insert( ActivePlayers, ply )

	umsg.Start("plane", ply )
		umsg.Char( 0 )
	umsg.End()

	ply._PlaneKills = 0

end

function HookPlayerSpawn( ply )
	if InGame( ply ) then
		SpawnPlayer( ply )
		return true
	end
end

function InGame( ply )
	for _, v in pairs( ActivePlayers ) do
		if v:EntIndex() == ply:EntIndex() then
			return true
		end
	end
	return table.HasValue( ActivePlayers, ply )
end

function RemovePlayer( ply )

	for k, v in pairs( ActivePlayers ) do
		if v == ply then
			table.remove( ActivePlayers, k )
		end
	end

	if IsValid( ply ) then
		umsg.Start("plane", ply )
			umsg.Char( 1 )
		umsg.End()

		if ply:Alive() then
			ply:Kill()
		end

		ply:ResetHull()
		ply:SetViewOffset( Vector(0,0,64) )
		ply:SetAllowFullRotation( false )
	end

end

function CheckNontheater( ply, loc )

	if InGame( ply ) && Location.IsTheater( loc ) then
		if ply:Alive() then
			ply:Kill()
		end
	end

end


function CheckRemoveBall( ply )

	if InGame( ply ) then

		if IsValid( ply.BallRaceBall ) then

			ply.BallRaceBall:Remove()
			ply.BallRaceBall = nil

		end

	end

end

function HookPlayerHurt( ent, inflictor, attacker, amount, dmginfo )

	if !InGame( ent ) then
		dmginfo:ScaleDamage( 0 )
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

	hook.Add("PlayerSpawn", "PlaneSpawn", HookPlayerSpawn )
	hook.Add("PlayerDeath", "PlaneDeath", HookOnDeath )
	hook.Add("EntityTakeDamage", "PlaneHurt", HookPlayerHurt )
	hook.Add("Location", "PlaneLocation", CheckNontheater )
	hook.Add("ShouldCollide", "PlaneShouldCollide", ShouldCollide )
	hook.Add("PlayerThink", "PlaneCheckRemoveBall", CheckRemoveBall )

	//Shared hooks
	hook.Add("Move", "PlaneMove", HookPlayerMove )
	hook.Add("CalcView", "PlaneCalcView", CalcView )
	hook.Add("CalcMainActivity", "PlaneAnim", HookPlayerAnim )

	for _, ply in pairs( player.GetAll() ) do
		ply._PlaneKills = nil
	end

	TotalMoneyEarned = 0

	if string.find( flags, "a" ) then
		ActiveSpawnPoints = SnowSpawnPoints
	else
		ActiveSpawnPoints = SpawnPos
	end

end

function End()

	hook.Remove("PlayerSpawn", "PlaneSpawn" )
	hook.Remove("PlayerDeath", "PlaneDeath" )
	hook.Remove("EntityTakeDamage", "PlaneHurt" )
	hook.Remove("Location", "PlaneLocation" )
	hook.Remove("ShouldCollide", "PlaneShouldCollide" )
	hook.Remove("PlayerThink", "PlaneCheckRemoveBall" )

	//Shared hooks
	hook.Remove("Move", "PlaneMove" )
	hook.Remove("CalcView", "PlaneCalcView" )
	hook.Remove("CalcMainActivity", "PlaneAnim" )



	for _, ply in pairs( table.Copy( ActivePlayers ) ) do
		SafeCall( RemovePlayer, ply )
		RemovePlayer( ply )

		if ply.plane then
			ply.plane:StopSound("plane_engine")
			ply.plane:Remove()
		end
		if ( IsValid( ply.m_entTrail ) ) then
			ply.m_entTrail:SetAttachment( nil )
			local trail = ply.m_entTrail
			timer.Simple( 1, function() if ( IsValid( trail ) ) then trail:Remove() end end )
		end
	end

	if IsValid( BallEntity ) then
		BallEntity:Remove()
	end

	for k,v in pairs(ents.GetAll()) do
		if v:GetClass() == "gmt_minigame_entrance" then
			v:Remove()
		end
	end

	local SendData = {}

	for _, ply in pairs( player.GetAll() ) do

		if ply._PlaneKills then
			SendData[ ply:EntIndex() ] = ply._PlaneKills
		end

	end

	umsg.Start("plane", nil )
		umsg.Char( 3 )
		umsg.Char( table.Count( SendData ) )
		umsg.Long( TotalMoneyEarned )

		for k, v in pairs( SendData ) do
			umsg.Char( k )
			umsg.Char( v )
		end

	umsg.End()

end

concommand.Add("gmt_planeleave", function( ply, cmd, args )

	if InGame( ply ) then
		RemovePlayer( ply )
	end

end )

	//umsg.Start("plane", self)
	//	umsg.String( str )
	//umsg.End()
