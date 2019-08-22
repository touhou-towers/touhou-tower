----------------------------------------------
PRIVATE_TEST_MODE = false

util.AddNetworkString("AdminMessage")
util.AddNetworkString("gmt_gamemodestart")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_post_events.lua")
AddCSLuaFile("calcview.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_gamemode.lua")
AddCSLuaFile("minigames/shared.lua")
AddCSLuaFile("cl_webboard.lua")
AddCSLuaFile("cl_hudchat.lua")
AddCSLuaFile("cl_tetris.lua")
AddCSLuaFile("uch_anims.lua")
AddCSLuaFile("event/cl_init.lua")

include("uch_anims.lua")
include("present_spawner.lua")
include("shared.lua")
include("sv_tetris.lua")
include("42.lua")
include("minigames/init.lua")
include("tetris/highscore.lua")
include("event/init.lua")

include( "animation.lua" ) // for gmt_force* commands
//include( "interaction.lua" )

//game.ConsoleCommand("sv_password peoplearefun\n")

CreateConVar("gmt_srvid", 99 )

-- Check if they can join

GM.AllowedList = {}
util.AddNetworkString("MultiserverJoinRemove")
--[[
timer.Create("gmt_timer_private",(60*2),0,function()
	if !PRIVATE_TEST_MODE then timer.Destroy("gmt_timer_private") return end
	MsgC( Color( 125, 255, 125 ), "GMT IS IN PRIVATE MODE, SET PRIVATE_TEST_MODE TO FALSE IN GMODTOWERLOBBY/INIT.LUA:2\n" )
end)
--]]
function GM:CheckPassword(steam, IP, sv_pass, cl_pass, name)
	steam = util.SteamIDFrom64(steam)

	if self.AllowedList[steam] or !PRIVATE_TEST_MODE then
		return true
	else
		MsgC(Color(51, 204, 51),name.." <"..steam.."> ("..IP..") tried to join the server.\n")
		return false, "no bro cring bro cring bro."
	end

	return true
end

function GM:PlayerLoadout( pl )
	return true
end

function GM:IsSpawnpointSuitable( ply, spawnpointent, bMakeSuitable )

	return true

end

local dons = {
	Vector(2056.412842, 1261.577637, 208.463181),
	Vector(2152.033203, 1261.568970, 208.448746),
	Vector(2247.797119, 1261.497437, 208.449326),
	Vector(2344.245117, 1261.497314, 208.493423),
	Vector(2440.292480, 1261.500366, 208.499008),
	Vector(2535.299561, 1261.316650, 208.340546),
	Vector(2631.354004, 1261.499268, 208.453522),
}


concommand.Add("gmt_disco",function(ply)
	if !ply:IsAdmin() then return end

	if ply:GetNWBool("IsDisco") then
		if timer.Exists("DiscoTimer") then
			timer.Destroy("DiscoTimer")
			ply:SetNWBool("IsDisco",false)
			return
		end
	end

	ply:SetNWBool("IsDisco",true)

	local red = Vector(1000000000,0,0)
	local green = Vector(0,1000000000,0)
	local blue = Vector(0,0,1000000000)

	ply:SetPlayerColor(red)

	timer.Create("DiscoTimer",0.25,0,function()
		if !IsValid(ply) then timer.Destroy("DiscoTimer") end

		if ply:GetPlayerColor() == red then
			ply:SetPlayerColor(green)
		elseif ply:GetPlayerColor() == green then
			ply:SetPlayerColor(blue)
		elseif ply:GetPlayerColor() == blue then
			ply:SetPlayerColor(red)
		end

	end)

end)

function AdminNotify(str)
	net.Start("AdminMessage")
	net.WriteEntity(nil)
	net.WriteString(str)
	net.Broadcast()
end

concommand.Add("gmt_adminmessage",function(ply, cmd, args, str)

	if !ply:IsAdmin() then return end

	net.Start("AdminMessage")
	net.WriteEntity(ply)
	net.WriteString(str)
	net.Broadcast()

end)

concommand.Add("remove_ent",function(ply,cmd,args,str)

	if !ply:IsAdmin() then return end

	for k,v in pairs(ents.GetAll()) do
		if v:GetClass() == str then
			v:Remove()
		end
	end

end)

concommand.Add("gmt_rc_boat",function(ply)

	if !ply:IsAdmin() then return end

	local obj = ents.Create("gmt_rc_boat")
	obj:SetPos(ply:GetEyeTrace().HitPos)
	obj:Spawn()


end)

concommand.Add("gmt_bigheads",function(ply)

	if !ply:IsAdmin() then return end

	for k,v in pairs(player.GetAll()) do
		local Head = v:LookupBone("ValveBiped.Bip01_Head1")
		v:ManipulateBoneScale(Head,Vector(5,5,5))
	end

end)

concommand.Add("gmt_chimera",function(ply)

	if !ply:IsAdmin() then return end

	ply:SetModel( "models/UCH/uchimeraGM.mdl" )
	ply:SetSkin( 0 )
	ply:SetBodygroup( 1, 1 )

	ply:SetWalkSpeed(100)
	ply:SetRunSpeed(250)

	ply:EmitSound("uch/music/endround/pigs_lose.mp3")

end)

concommand.Add("gmt_trex",function(ply)

	if !ply:IsAdmin() then return end

	ply:SetModel( "models/dinosaurs/trex.mdl" )
	ply:SetSkin( 0 )
	ply:SetBodygroup( 1, 1 )

end)

concommand.Add("gmt_dog",function(ply)

	if !ply:IsAdmin() then return end

	ply:SetModel( "models/zom/dog.mdl" )
	ply:SetSkin( 0 )
	ply:SetBodygroup( 1, 1 )

end)

concommand.Add("gmt_setalldog",function(ply)

	if !ply:IsAdmin() then return end

	for k,v in pairs(player.GetAll()) do
		v:SetModel( "models/zom/dog.mdl" )
		v:SetSkin( 0 )
		v:SetBodygroup( 1, 1 )
	end

end)

concommand.Add("gmt_spider",function(ply)

	if !ply:IsAdmin() then return end

	ply:SetModel( "models/npc/spider_regular/npc_spider_regular.mdl" )
	ply:SetSkin( 0 )
	ply:SetBodygroup( 1, 1 )

end)

concommand.Add("gmt_salsa",function(ply)
	if ply:IsAdmin() and ply:GetModel() == "models/uch/uchimeragm.mdl" then
		ply:EmitSound("uch/music/endround/salsa.mp3")
		timer.Create("ConfettiSalsa",0.25,70,function()
			local vPoint = ply:GetPos()
			local effectdata = EffectData()
			effectdata:SetOrigin( vPoint )
			util.Effect( "confetti", effectdata )
		end)
	end
end)

hook.Add("PlayerFootstep","ChimeraSteps",function(ply)

	if ply:IsAdmin() and ply:GetModel() == "models/uch/uchimeragm.mdl" then
		ply:EmitSound( "UCH/chimera/step.wav", 82, math.random( 94, 105 ))
		util.ScreenShake( ply:GetPos(), 5, 5, .5, ( 450 * 1.85 ) )
		return true
	end

end)
 
hook.Add("PlayerSpawn","UCHMilestoneFix", function(ply)

	local list = ply:GetEquipedItems()

	SpawnPlayerUCH(ply, list)
	
end)

function SpawnPlayerUCH(ply, list)

	if list == nil then
		timer.Simple(1, function() SpawnPlayerUCH(ply,ply:GetEquipedItems()) end)
		return
	end

	for k, v in pairs( list ) do

		if v.Name == "Pigmask" then
			print(ply)
			timer.Simple(0.5, function()
				UCHAnim.SetupPlayer( ply, UCHAnim.TYPE_PIG )
			end)
				
		elseif v.Name == "Ghost" then
			timer.Simple(0.5, function()
				UCHAnim.SetupPlayer( ply, UCHAnim.TYPE_GHOST )
			end)
		end

	end
end

hook.Add( "KeyPress", "Bite", function( ply, key )

	if ply:IsAdmin() and ply:GetModel() == "models/uch/uchimeragm.mdl" and ply:Alive() then
		if ( key == IN_ATTACK ) then
			Bite(ply)
		end
	end

end )

function FindThingsToBite(ply)

	local tbl = {}

	local pos = ply:GetShootPos()
	local fwd = ply:GetForward()

	local function playerGetAllMinus( ent )

		local tbl = {}

		for k, v in pairs( player.GetAll() ) do
			if v != ent then
				table.insert( tbl, v )
			end
		end

		return tbl

	end

	fwd.z = 0
	fwd:Normalize()
	local vec = ( ( pos + Vector( 0, 0, -16 ) ) + ( fwd * 60 ) )
	local rad = 70

	debugoverlay.Sphere( vec, rad )
	for k, v in pairs( ents.FindInSphere( vec, rad ) ) do

		if v:IsPlayer() then

			local pos = ply:GetShootPos()
			local epos = v:IsPlayer() && v:GetShootPos() || v:GetPos()
			local tr = util.QuickTrace( pos, (epos - pos ) * 10000, playerGetAllMinus( v ) )
			debugoverlay.Line( pos, tr.HitPos, 3, Color( 255, 0, 0 ) )

			if IsValid( tr.Entity ) && tr.Entity == v then
				table.insert( tbl, v )
			end

		end

	end

	return tbl

end

function Bite(ply)
	if timeout then return end
	Animation.PlayAnim( ply, ACT_MELEE_ATTACK1 )
	local timeout = true
	ply:Freeze(true)
	ply:EmitSound( "UCH/chimera/bite.mp3", 80, math.random( 94, 105 ) )
	timer.Simple(0.75,function() timeout = false ply:Freeze(false) end)

	local tbl = FindThingsToBite(ply)
	if #tbl >= 1 then
		for k, v in pairs( tbl ) do
			if v:IsPlayer() then
				v:Freeze( true )
			end
			timer.Simple( .32, function()
				if IsValid( ply ) && IsValid( v ) then
					v:Kill()
					v:EmitSound("uch/pigs/die.wav")
					ply:EmitSound("uch/music/roundtimer_add.wav")
				end
			end )
		end
	end

end

concommand.Add( "gmt_enablegod", function( ply, cmd, args )

	local val = tonumber( args[1] ) or 0

	if val == 1 then
		ply.IsGodMode = true
	else
		ply.IsGodMode = false
	end

end )

/*hook.Add("PlayerInitialSpawn", "PlayerGod", function(ply)

	ply.IsGodMode = true

end)*/

function GM:EntityTakeDamage( ent, dmginfo  )

	if ent:IsNPC() then
		dmginfo:ScaleDamage( 0.0 )
	end

	if ent:IsPlayer() && ent.IsGodMode then //why this? because we want to be able to override it if needed
		dmginfo:ScaleDamage( 0.0 )
	end

end

concommand.Add("gmt_fountain_train",function(ply,_,_,str)

	if !ply:IsAdmin() or str == nil then return end

	if tonumber(str) == 1 then
		local Train = ents.Create( "gmt_train" )
		Train:SetPos( Vector( 927.268372, -1472.406006, 1 ) )
		Train:Spawn()
		Train:Activate()
		Train:SetRadius( 145 )
		Train:SetTrainVelocity( 125 )
		Train:SetTrainCount( 15 )
	elseif tonumber(str) == 0 then
		for k,v in pairs(ents.GetAll()) do
			if v:GetClass() == "gmt_train" then
				if GTowerLocation:FindPlacePos(v:GetPos()) == 2 then
				v:Remove()
				end
			end
		end
	else
		ply:Msg2("gmt_fountain_train 1 | turns on the fountain train")
		ply:Msg2("gmt_fountain_train 0 | turns off the fountain train")
	end

end)

concommand.Add("toss", function(ply, cmd, args)
		if !ply:IsAdmin() or (ply.NextToss and CurTime() < ply.NextToss) then return end

		ply.NextToss = CurTime() + .5

		local num = math.Clamp(tonumber(args[1]) or 1, 1, 10)

		for i = 1,num do
			local eye = ply:EyeAngles()

			local aim = eye - Angle(30, 0, 0)
			local aimforward = aim:Forward()

			local trace = util.TraceLine({start=ply:GetShootPos(), endpos=ply:GetShootPos() + ply:GetAimVector() * 30, filter=ply})
			local start = trace.HitPos - (aimforward * num * 5) - (aimforward * 10)

			local corn = ents.Create("candycorn")

			if i > 1 then
				local offset = eye:Up() * math.random(-15,15) + eye:Right() * math.random(-15, 15) + (aimforward * i * 5)
				corn:SetPos(start + offset)
			else
				corn:SetPos(start)
			end

			corn:SetAngles(VectorRand():Angle())
			corn:Spawn()

			local phys = corn:GetPhysicsObject()
			if IsValid(phys) then
				phys:Wake()
				phys:SetVelocity(aimforward * 300)
			end
		end
	end)

concommand.Add("morebeer", function(ply, cmd, args)
		if !ply:IsAdmin() or (ply.NextBeer and CurTime() < ply.NextBeer) then return end

		ply.NextBeer = CurTime() + .5

		local eye = ply:EyeAngles()

		local aim = eye - Angle(30, 0, 0)
		local aimforward = aim:Forward()

		local trace = util.GetPlayerTrace(ply)
		trace = util.TraceLine(trace)

		local beer = ents.Create("alcohol_bottle")

		beer:SetPos(trace.HitPos)
		beer:Spawn()
		local phys = beer:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
end)

concommand.Add("gmt_giveammo", function(ply, cmd, args) --Temporary fix.
	if !ply:GetSetting( "GTAllowWeapons" ) then return end
	/*if ply:GetActiveWeapon() == NULL or ply:GetActiveWeapon():GetPrimaryAmmoType() == "-1" then
		ply:GiveAmmo(tonumber(args[1]) or 30, ply:GetActiveWeapon():GetPrimaryAmmoType(), true)
	end*/

	ply:GiveAmmo( 50, "SMG1", true )
	ply:GiveAmmo( 50, "AR2", true )
	ply:GiveAmmo( 50, "AlyxGun", true )
	ply:GiveAmmo( 50, "Pistol", true )
	ply:GiveAmmo( 50, "SMG1", true )
	ply:GiveAmmo( 50, "357", true )
	ply:GiveAmmo( 50, "XBowBolt", true )
	ply:GiveAmmo( 50, "Buckshot", true )
	ply:GiveAmmo( 50, "RPG_Round", true )
	ply:GiveAmmo( 50, "SMG1_Grenade", true )
	ply:GiveAmmo( 50, "SniperRound", true )
	ply:GiveAmmo( 50, "SniperPenetratedRound", true )
	ply:GiveAmmo( 50, "Grenade", true )
	ply:GiveAmmo( 50, "Trumper", true )
	ply:GiveAmmo( 50, "Gravity", true )
	ply:GiveAmmo( 50, "Battery", true )
	ply:GiveAmmo( 50, "GaussEnergy", true )
	ply:GiveAmmo( 50, "CombineCannon", true )
	ply:GiveAmmo( 50, "AirboatGun", true )
	ply:GiveAmmo( 50, "StriderMinigun", true )
	ply:GiveAmmo( 50, "HelicopterGun", true )
	ply:GiveAmmo( 50, "AR2AltFire", true )
	ply:GiveAmmo( 50, "slam", true )
end)

local function AddSoundScape( sound, pos )
	for _, v in ipairs( pos ) do

		local ent = ents.Create( "gmt_soundscape" )

		ent:SetPos( v[ 1 ] )
		ent:Spawn()
		ent:Activate()

		ent.VolScale = v[ 2 ]
		ent.SoundFile = sound

	end
end

local function AddMultiServer( pos, ang, id, oldSky, newSky )

	local ms = ents.Create( "gmt_multiserver" )
	ms:SetPos( pos )
	ms:SetAngles( ang )
	ms:Spawn()
	ms:Activate()
	ms:SetId( id )

	local phys = ms:GetPhysicsObject()
	if ( phys:IsValid() ) then
		phys:EnableMotion( false )
	end

	if ( oldSky == nil ) then return ms end

	for _, v in pairs( ents.FindByClass( "gmt_skymsg" ) ) do
		if ( v:GetSkin() == oldSky ) then
			v:SetSkin( newSky )
		end
	end

	return ms

end

local function AddMerch( class, pos, ang )

	local merch = ents.Create( class )
	merch:SetPos( pos )
	merch:SetAngles( ang )
	merch:Spawn()
	merch:Activate()

	local phys = merch:GetPhysicsObject()
	if ( phys:IsValid() ) then
		phys:EnableMotion( false )
	end

	return merch

end


hook.Add("PlayerSpawn", "PISCollisions", function(ply)
	--ply:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	ply:CrosshairDisable()
end)

hook.Add("Initialize", "NoFishy", function()
	
	for k,v in pairs(ents.FindByClass("func_fish_pool")) do
		v:Remove()
	end

end)

hook.Add("InitPostEntity", "GMTPostEntity", function()

	/*for k,v in pairs(dons) do
		local ent = ents.Create("double_or_nothing")
		ent:SetPos( v )
		ent:SetAngles( Angle(0, 90, 0) )
		ent:Spawn()
	end*/

	// Update sign
	
	local board = ents.Create("gmt_websign")
	if time.IsHalloween() then
		board:SetPos( Vector(83, -1071, 363) )
		board:SetAngles( Angle(0,45,90) )
	else
		board:SetPos( Vector(1533, -819, 347) )
		board:SetAngles( Angle(0,-45,90) )
	end

	board:Spawn()

	for k,v in pairs(ents.FindInSphere(Vector(10804, 8605, 6994), 64)) do
		if v:GetClass() == "gmt_skymsg" then v:Remove() end
	end

	// Removes Trivia Tables till they're fixed.
	--for k,v in pairs(ents.FindByClass("gmt_jeo_table")) do v:Remove() end

	local ent = ents.Create("gmt_trunk")
	ent:AllowAllUsers()
	ent:SetPos( Vector(-34.3125, 765.5625, 34.5000) )
	ent:SetAngles( Angle(0, -65.840218, 0) )
	ent:Spawn()

	for _, v in pairs( ents.FindInSphere( Vector( -604.0000, -3296.0000, 1413.2500 ), 128 ) ) do
		if v:IsNPC() then
			v:Remove()
		end
	end

	for _, v in pairs( ents.GetAll() ) do
		if v:GetClass() == "gmt_npc_posters" and GTowerLocation:FindPlacePos(v:GetPos()) == 45 then
			local ToyPos = Vector(2334,1648,280)
			local ToyAng = v:GetAngles()
			v:Remove()
		end
	end

	/* Virus Multiserver */
	AddMultiServer(
		Vector( 11327.9980 + 20, 11412.8750, 6700.390137 ),
		Angle( 0, -180, 0 ),
		6, // server id
		18, 35 // skymsg skin translation
	)

	/* Ultimate Chimera Multiserver */
	AddMultiServer(
		Vector( 9685, 11955.371094, 6700.390137 ),
		Angle( 0, 0, 0 ),
		7, // server id
		26, 36 // skymsg skin translation
	)

	/* Ball Race 2 Multiserver
	AddMultiServer(
		Vector( 9804.210938, 11239.888672 , 6700.390137 ),
		Angle( 0, 45, 0 ),
		8, // server id
		nil, nil // no skymsg translation
	)*/

	/* Minigolf Multiserver */
	AddMultiServer(
		Vector( 10233.55, 8608.03 , 6700.390137 ),
		Angle( 0, 89, 0 ),
		14, // server id
		nil, nil // no skymsg translation
	)

	/* Source Karts Multiserver */
	AddMultiServer(
		Vector( 9685, 9295, 6700.390137 ),
		Angle( 0, 0, 0 ),
		16, // server id
		nil, nil // no skymsg translation
	)

	/* Zombie Massacre Multiserver */
	AddMultiServer(
		Vector( 11259.968750, 11967.382813, 6700.390137 ),
		Angle( 0, -180, 0 ),
		8, // server id
		nil, nil // no skymsg translation
	)

if game.GetMap() == "gmt_build0h2" then
	AddMerch(
		"gmt_npc_merchant",
		Vector( -600.004883, -3301.688477, 1483.185059 ),
		Angle( 0, 0, 0 )
	) 
end
if game.GetMap() == "gmt_build001" then
	AddMerch( -- Not needed
		"gmt_npc_building",
		Vector( -645.0625, 840.0313, -7.9688 ),
		Angle( 0, -113.120, 0 )
	)
end
if game.GetMap() == "gmt_build0h2" then
	AddMerch(
		"gmt_npc_models",
		Vector(1900.283447, 600.637085, 52.716148 ),
		Angle( 0, -180, 0 )
	)
elseif game.GetMap() == "gmt_build001" then
	AddMerch(
		"gmt_npc_models",
		Vector(2095.818604, 633.988953, 48.031250 ),
		Angle( 0, -180, 0 )
	)
end
	AddMerch(
		"gmt_npc_posters",
		Vector( 2334, 1650, 280 ),
		Angle( 0, -180, 0 )
	)
	AddMerch(
		"gmt_npc_mac",
		Vector( -12148, 9209, -62 ),
		Angle( 0, -128, 0 )
	)
	AddMerch(
		"gmt_piano",
		Vector( 1837.096191, -1286.637329, 0 ),
		Angle( 0, -180, 0 )
	)
	AddMerch(
		"gmt_npc_toys",
		Vector(2333.98,1600,280),
		Angle( 0, 180, 0 )
	)
	AddMerch(
		"gmt_npc_pets",
		Vector( 1878.457642, 813.888000, -15.968750 ),
		Angle( 0, -138.398, 0 )
	)
	AddMerch(
		"gmt_npc_music",
		Vector( -709.573975, 1575.819458, 216.031250 ),
		Angle( 0, 0, 0 )
	)
	AddMerch(
		"gmt_npc_vip",
		Vector( 160,-2047,64 ),
		Angle( 0, 45, 0 )
	)
	AddMerch(
		"gmt_npc_duel",
		Vector( 3199.501221, 592.292969, 256.968658 ),
		Angle( 0, 180, 0 )
	)
	AddMerch(
		"gmt_npc_bathroom",
		Vector( 2723.948975, 3434.844482, 70.031250 ),
		Angle( 0.000, 0.000, 0.000 )
	)



	/*AddSoundScape( "GModTower/lobby/firework/firework_explode.wav", {
		{ Vector( 919.9500,		-1469.4355,	1062.1792	), 1	}, // lobby
		{ Vector( 934.0074,		904.5416,	633.0622	), 0.75	}, // entertainment plaza
		{ Vector( -1397.5425,	2280.9324,	184.3623	), 0.25 }, // arcade
	} )*/


	--Fix Doors (gmt_build002)
	--for k,v in pairs(ents.FindByClass("func_door_rotating")) do
	--	v:SetKeyValue( "spawnflags", 16 )
	--end

	timer.Simple(1,function()
		for k,v in pairs(ents.FindByClass("gmt_npc_merchant")) do
			local merchant = ents.Create("gmt_npc_merchant")
			merchant:SetPos(v:GetPos())
			merchant:SetAngles(v:GetAngles())
			v:Remove()
			merchant:Spawn()
		end

		for k,v in pairs(ents.FindByClass("gmt_npc_basical")) do
			local merchant = ents.Create("gmt_npc_basical")
			merchant:SetPos(v:GetPos())
			merchant:SetAngles(v:GetAngles())
			v:Remove()
			merchant:Spawn()
		end

		for k,v in pairs(ents.FindByClass("gmt_npc_electronic")) do
			local merchant = ents.Create("gmt_npc_electronic")
			merchant:SetPos(v:GetPos())
			merchant:SetAngles(v:GetAngles())
			v:Remove()
			merchant:Spawn()
		end
	end)

end )

hook.Add("PlayerSwitchFlashlight", "GMTFlashLight", function(ply, isOn)

		if !ply:IsAdmin() then
			if !ply.FlashLightTime then ply.FlashLightTime = 0 end
			if ply.FlashLightTime > CurTime() then return false end

			ply.FlashLightTime = CurTime() + 1
		end

		return true

	end)

hook.Add("GTowerPhysgunPickup", "DisablePrivAdminPickup", function(pl, ent)
	if IsValid( ent ) then
		if ( ent:GetModel() == "models/gmod_tower/suite_bath.mdl" ) then return false end
		if ( ent:GetClass() == "player" && ent:IsPrivAdmin() ) then return false end
	end
end)

hook.Add("PhysgunDrop", "ResetPISCollisions", function(pl, ent)
	if IsValid( ent ) && ent:GetClass() == "player"  then
		ent:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	end
end)

hook.Add("Location","DisableLocJetpack",function(ply,loc)
	if loc == 51 then
		ply._DisabledJetpack = true
	else
		ply._DisabledJetpack = false
	end
end)
