AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

include("shared.lua")

local SpawnPos = {
	{
		{Vector(910.5313, 1788.0000, 308.7500), Angle( 0.000, -90.401, 0.000)},
		{Vector(753.1563, -267.6250, 197.4688), Angle( 0.000, -108.441, 0.000)},
		{Vector(583.9375, -1806.3750, 547.8438), Angle( 0.000, -8.121, 0.000)},
		{Vector(1158.9688, -1917.4063, 351.0625), Angle( 0.000, 85.599, 0.000)},
		{Vector(1424.0313, -292.4375, 335.1875), Angle( 0.000, 77.239, 0.000)},
		{Vector(1727.6250, 648.5625, 306.5313), Angle( 0.000, 90.439, 0.000)},
		{Vector(1286.4375, 2230.4063, 256.5000), Angle( 0.000, -105.001, 0.000)},
		{Vector(620.2813, 1915.2813, 32.5938), Angle( 0.000, -81.681, 0.000)},
		{Vector(947.8125, 1119.6563, 86.0625), Angle( 0.000, -89.161, 0.000)},
		{Vector(802.5938, 575.6250, 70.2813), Angle( 0.000, -91.361, 0.000)},
		{Vector(1155.2188, 851.2813, 152.9375), Angle( 0.000, 92.119, 0.000)},
		{Vector(856.2188, 1571.7500, 107.1563), Angle( 0.000, -89.681, 0.000)},
		{Vector(908.5625, 623.9375, 101.2500), Angle( 0.000, -89.241, 0.000)},
		{Vector(650.8438, -557.2500, 26.3125), Angle( 0.000, -80.441, 0.000)},
		{Vector(736.3438, 330.7500, 26.2500), Angle( 0.000, 63.439, 0.000)},
		{Vector(1133.3750, 1464.9063, 439.1250), Angle( 0.000, 107.879, 0.000)},
		{Vector(1092.8125, 929.5938, 462.8438), Angle( 0.000, -108.241, 0.000)},
		{Vector(459.4063, -1146.7813, 1617.6250), Angle( 0.000, -83.600, 0.000)},
		{Vector(1043.7188, -1844.3438, 1288.7188), Angle( 0.000, 19.360, 0.000)},
		{Vector(1214.3438, -1100.4063, 493.5625), Angle( 0.000, 94.160, 0.000)},
		{Vector(796.5313, -333.5625, 206.8750), Angle( 8.920, 92.840, 0.000)}
	},
	{
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
}

module("minigames.plane",package.seeall )

ActiveSettings = nil
ActivePlayers = {}

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

function AddPlanePart( pl, pos, ang, mdl )
	
	pos = pos + Vector( 0, 0, -3 )
	
	local ent = ents.Create( "prop_dynamic" )

		ent:SetModel( mdl )
		ent:Spawn()
		
		ent:SetParent( pl )
		ent:SetPos( pos )
		ent:SetAngles( ang )
		
	pl.parts = pl.parts or {}
	table.insert( pl.parts, ent )
	
end

function SpawnPlayer( ply )

	ply:DrawViewModel( false )
	//ply:SetModel("models/props_c17/doll01.mdl")
	
	local ActiveSpawnPoints = SpawnPos[ ActiveSettings.Location ]
	local RandomPos = ActiveSpawnPoints[ math.random( 1, #ActiveSpawnPoints ) ]
	
	ply:SetPos( RandomPos[1] )
	ply:SetAllowFullRotation( true )
	
	ply:SetHull( Vector( -16, -16, -16 ), Vector( 16, 16, 16 ) )
	ply:SetViewOffset( Vector( 0, 0, 0 ) )
	ply:SetMoveType( MOVETYPE_NOCLIP )
	
	ply:SetPos( ply:GetPos() )
	ply:SetAngles( Angle( 0, 0, 0 ) )
	
	AddPlanePart( ply, Vector( 0, 0, -7 ), Angle( 0, 92, 0 ), "models/props_junk/plasticcrate01a.mdl" )
	AddPlanePart( ply, Vector( 0, 19, -9 ), Angle( -1.682, 120.148, 10.0717 ), "models/props_c17/playground_swingset_seat01a.mdl" )
	AddPlanePart( ply, Vector( 0, -19, -9 ), Angle( -1.682, 70.648, 10.0717 ), "models/props_c17/playground_swingset_seat01a.mdl" )
	AddPlanePart( ply, Vector( 21, 0, -9 ), Angle( -90, 270 + 180, -90 ), "models/props_junk/trafficcone001a.mdl" )
	AddPlanePart( ply, Vector( -18, -1, -7 ), Angle( -90, 90 + 180, -90 ), "models/props_lab/powerbox02d.mdl" )
	
	ply._LastPlaneSend = nil //Make sure it is going to be sent
	SetPlaneVel( ply, 100, RandomPos[2] )
	ply:GodDisable()
	
	if !ply:HasWeapon("weapon_planegun") then
		ply.CanPickupWeapons = true
		ply:Give( "weapon_planegun" )
		ply.CanPickupWeapons = false
	end
	
	ply:SetAnimation( ply:LookupSequence( "drive_jeep" ) )
end

function ExplodePlaneParts( ply )

	if ( !ply.parts ) then return end
	
	for _, ent in pairs( ply.parts ) do
		if IsValid( ent ) then	
			ent:Remove()
		end
	end
	
	ply.parts = {}

end

function HookOnDeath( pl, inf, attacker )
	
	ExplodePlaneParts( pl )
	
	if InGame( pl ) && InGame( attacker ) && IsValid( attacker ) && attacker:IsPlayer() && attacker != pl then
		attacker:AddMoney( ActiveSettings.Money )
		attacker._PlaneKills = attacker._PlaneKills + 1
		TotalMoneyEarned = TotalMoneyEarned + ActiveSettings.Money
	end

end

function OnEntUse( ply, caller )
	if ply:IsPlayer() then
		AddPlayer( ply )
		ply:Spawn()
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
	return table.HasValue( ActivePlayers, ply )
end

function RemovePlayer( ply )
	
	for k, v in pairs( ActivePlayers ) do
		if v == ply then
			table.remove( ActivePlayers, k )
		end
	end
	
	ExplodePlaneParts( ply )
	
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

function HookPlayerAnim( ply, anim )
	
	if InGame( ply ) then
		
		local seq = ply:LookupSequence( "drive_jeep" )
		
		if (ply:GetSequence() != seq) then
			
			ply:SetPlaybackRate( 1.0 )
			ply:ResetSequence( seq )
			ply:SetCycle( 0 )
			
		end
		
		return true
	end
	
end

function CheckNontheater( ply, loc )

	if InGame( ply ) && Location.IsTheater( loc ) then
		if ply:Alive() then
			ply:Kill()
		end
	end

end


function Start(SettingsTemp)
	
	ActiveSettings = SettingsTemp // someone needs to fix this
	
	if !IsValid( BallEntity ) then
		BallEntity = ents.Create("gmt_entuse")
		BallEntity:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
		BallEntity:SetPos( Vector(933.318970, -1474.828247, 183.693512) )
		BallEntity:Spawn()
		BallEntity:SetUse( OnEntUse )
	end
	
	hook.Add("PlayerSpawn", "PlaneSpawn", HookPlayerSpawn )
	hook.Add("PlayerDeath", "PlaneDeath", HookOnDeath )
	hook.Add("SetPlayerAnimation", "PlaneAnim", HookPlayerAnim )
	hook.Add("Location", "PlaneLocation", CheckNontheater )
	hook.Add("ShouldCollide", "PlaneShouldCollide", ShouldCollide )
	
	//Shared hooks
	hook.Add("Move", "PlaneMove", HookPlayerMove )
	hook.Add("CalcView", "PlaneCalcView", CalcView )
	
	for _, ply in pairs( player.GetAll() ) do
		ply._PlaneKills = nil
	end
	
	TotalMoneyEarned = 0
	
end

function End()
	
	hook.Remove("PlayerSpawn", "PlaneSpawn" )
	hook.Remove("PlayerDeath", "PlaneDeath" )
	hook.Remove("Location", "PlaneLocation" )
	hook.Remove("ShouldCollide", "PlaneShouldCollide" )
	hook.Remove("SetPlayerAnimation", "PlaneAnim" )
	
	//Shared hooks
	hook.Remove("Move", "PlaneMove" )
	hook.Remove("CalcView", "PlaneCalcView" )
	
	
	
	for _, ply in pairs( table.Copy( ActivePlayers ) ) do
		SafeCall( RemovePlayer, ply )
	end
	
	if IsValid( BallEntity ) then
		BallEntity:Remove()
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

concommand.Add("gmt_planeleave", function( ply )
	
	if InGame( ply ) then
		RemovePlayer( ply )
	end

end )