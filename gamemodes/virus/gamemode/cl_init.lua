include( "shared.lua" )
include( "sh_payout.lua" )

include( "cl_deathnotice.lua" )
include( "cl_scoreboard.lua" )
include( "cl_hud.lua" )
include( "cl_post_events.lua" )
include( "cl_hudmessage.lua" )
include( "cl_radar.lua" )

GM.DamageFade = 255
GM.NextFadeThink = 0

local WaitingForPlayersMusic = "GModTower/virus/waiting_forplayers" .. math.random( 1, 8 ) .. ".mp3" // this one is not synchronized with other clients
local WaitingForInfectionMusic = "GModTower/virus/waiting_forinfection"
local RoundMusic = "GModTower/virus/roundplay"
local LastAliveMusic = "GModTower/virus/roundlastalive"

function GM:Initialize()
	self.DamageFade = 0
	self.NextFadeThink = 0
end

function GM:CreateMove( cmd )

	if ( cmd:KeyDown( IN_DUCK ) ) then
		cmd:SetButtons( cmd:GetButtons() - IN_DUCK ) // how do i bitwise?
	end

	if ( cmd:KeyDown( IN_JUMP ) ) then
		cmd:SetButtons( cmd:GetButtons() - IN_JUMP )
	end

end

function GM:InitPostEntity()

	LocalPlayer().WaitingForPlayers = CreateSound( LocalPlayer(), WaitingForPlayersMusic )

	LocalPlayer().VirusWin = CreateSound( LocalPlayer(), "GModTower/virus/roundend_virus.mp3" )
	LocalPlayer().SurvivorsWin = CreateSound( LocalPlayer(), "GModTower/virus/roundend_survivors.mp3" )

	LocalPlayer().Stinger = CreateSound( LocalPlayer(), "GModTower/virus/stinger.mp3" )

	LocalPlayer().LocalInfected = CreateSound( LocalPlayer(), "ambient/fire/ignite.wav" )

	timer.Simple( 1, function()
		if ( game.GetWorld().State == STATUS_WAITING ) then
			LocalPlayer().WaitingForPlayers:PlayEx( 1, 100 )
			LocalPlayer().IsThirdPerson = true
		end
	end )

end

local TimeLeftUsed = { }

function GM:Think()

	for _, v in ipairs( player.GetAll() ) do
		if v.IsVirus then
			self:LightThink( v )
		end

		local Flame = v:GetNetworkedEntity("Flame1")
		local Flame2 = v:GetNetworkedEntity("Flame2")

		if IsValid( Flame ) && IsValid( Flame2 ) then

			--local Torso = v:LookupBone( "ValveBiped.Bip01_Spine2" )
			local Torso = v:LookupBone( "ValveBiped.Bip01_Spine" )
			local pos, ang = v:GetBonePosition( Torso )

			Flame:SetPos( pos )
			Flame2:SetPos( pos )

		end

	end

	if ( CurTime() >= self.NextFadeThink ) then

		self.DamageFade = self.DamageFade - 1

		if self.DamageFade < 0 then
			self.DamageFade = 0
		end

		self.NextFadeThink = CurTime() + .01

	end

	if ( game.GetWorld().State != STATUS_PLAYING ) then return end

	local endTime = game.GetWorld().Time
	local timeLeft = endTime - CurTime() - 1 // adjusting for hud message sliding

	if ( timeLeft <= 0 ) then
		timeLeft = 0
	end

	timeLeft = math.Round( timeLeft )

	if ( TimeLeftUsed[ timeLeft ] ) != nil then return end

	if ( timeLeft == 15 ) then

		HudMessage( HudMessages[ 5 /* 15 seconds remaining! */ ], 5, nil, true )

		LocalPlayer():EmitSound( "GModTower/virus/ui/navigate.wav", 300, 100 )

		TimeLeftUsed[ timeLeft ] = timeLeft

	elseif ( timeLeft <= 5 && timeLeft > 0 ) then

		local msgIndex = 6 + (5 - timeLeft)
		HudMessage( HudMessages[ msgIndex ], 0.7, "CountDown", true )

		local pitch = 100
		if ( timeLeft == 1 ) then
			pitch = 150
		end

		LocalPlayer():EmitSound( "GModTower/virus/ui/navigate2.wav", 300, pitch )

		TimeLeftUsed[ timeLeft ] = timeLeft

	end
end

function GM:LightThink( ply )
	if !ply:Alive() then return end

	local dlight = DynamicLight( ply:EntIndex() )
	if ( dlight ) then
		dlight.Pos = ply:GetPos() + Vector( 0, 0, 40 )
		dlight.r = 150
		dlight.g = 255
		dlight.b = 150
		dlight.Brightness = 1
		dlight.Decay = 768
		dlight.Size = 192
		dlight.DieTime = CurTime() + 1
	end

end


function GM:PlayerBindPress( ply, bind, pressed )
	if ( bind == "+jump" || bind == "+duck" ) then return true end

	if ( bind == "+menu" && pressed ) then
		LocalPlayer():ConCommand( "lastinv" )
		return true
	end

	if ( bind == "+menu_context" && pressed ) then
		LocalPlayer():ConCommand( "use_adrenaline" )
		return true
	end


	return false
end

local WalkTimer = 0
local VelSmooth = 0

local VirusTP = CreateClientConVar("gmt_firstpersonvirus", "0")

function GM:CalcView( ply, pos, ang, fov )

	if (ply.IsVirus && !VirusTP:GetBool()) || game.GetWorld().State == STATUS_WAITING then

		local dist = 150
		local center = ply:GetPos() + Vector( 0, 0, 75 )
		local trace = util.TraceLine( {start = center, endpos = center + ang:Forward() * -dist, mask = MASK_OPAQUE} )
		if trace.Fraction < 1 then
			dist = dist * trace.Fraction
		end

		return {
			["origin"] = center + (ang:Forward() * -dist * 0.95),
			["angles"] = Angle(ang.p + 2, ang.y, ang.r)
		}

	end

	local rag = ply:GetRagdollEntity()

	if IsValid( rag ) then
		local att = rag:GetAttachment( rag:LookupAttachment("eyes") )
 		return self.BaseClass:CalcView( ply, att.Pos, att.Ang, fov )
 	end

	if !ply:Alive() then return end

	local vel = ply:GetVelocity()
	local ang = ply:EyeAngles()

	VelSmooth = VelSmooth * 0.9 + vel:Length() * 0.1
	WalkTimer = WalkTimer + VelSmooth * FrameTime() * 0.05

	ang.roll = ang.roll + ang:Right():DotProduct( vel ) * 0.01

	if ( ply:GetGroundEntity() != NULL ) then
		ang.roll = ang.roll + math.sin( WalkTimer ) * VelSmooth * 0.001
		ang.pitch = ang.pitch + math.sin( WalkTimer * 0.5 ) * VelSmooth * 0.001
	end

	return self.BaseClass:CalcView( ply, pos, ang, fov )

end

hook.Add("ShouldDrawLocalPlayer", "ThirdDrawLocal", function()
	return (LocalPlayer().IsVirus && !VirusTP:GetBool()) || game.GetWorld().State == STATUS_WAITING
end)

local function ClientStartRound( um )

	local randSong = um:ReadChar()

	TimeLeftUsed = {}

	for _, v in ipairs( player.GetAll() ) do
		v.IsVirus = false
	end

	if ( !IsValid( LocalPlayer() ) ) then return end

	LocalPlayer():ConCommand( "-showscores" )
	LocalPlayer():ConCommand( "r_cleardecals" )

	LocalPlayer().WaitingForPlayers:Stop()

	if ( LocalPlayer().WaitingForInfection ) then
		LocalPlayer().WaitingForInfection:Stop()
		LocalPlayer().WaitingForInfection = nil
	end

	LocalPlayer().WaitingForInfection = CreateSound( LocalPlayer(), WaitingForInfectionMusic .. math.random( 1, 8 ) .. ".mp3" )

	LocalPlayer().WaitingForInfection:PlayEx( 1, 100 )

	LocalPlayer().VirusWin:Stop()
	LocalPlayer().SurvivorsWin:Stop()

	LocalPlayer().IsThirdPerson = false
	LocalPlayer().IsVirus = false

end

local function ClientEndRound( um )
	local virusWins = um:ReadBool()

	if ( !IsValid( LocalPlayer() ) ) then return end

	LocalPlayer().WaitingForPlayers:Stop() // just in case

	timer.Simple( 4, function()
		LocalPlayer():ConCommand( "+showscores" )
		LocalPlayer():EmitSound( "GModTower/virus/ui/menu.wav", 300, 100 )
	end )

	if ( virusWins ) then
		LocalPlayer().VirusWin:PlayEx( 1, 100 )
	else
		LocalPlayer().SurvivorsWin:PlayEx( 1, 100 )
	end

	if ( LocalPlayer().RoundMusic ) then
		LocalPlayer().RoundMusic:Stop()
		LocalPlayer().RoundMusic = nil
	end

	LocalPlayer().Stinger:Stop() // so we can replay it next round

	if ( LocalPlayer().LastSurvivor ) then
		LocalPlayer().LastSurvivor:Stop()
		LocalPlayer().LastSurvivor = nil
	end

	LocalPlayer().LocalInfected:Stop()

	game.GetWorld().Started = false

end

local function ClientInfected( um )

	local virusEnt = um:ReadEntity()
	virusEnt.IsVirus = true

	local infector = um:ReadEntity()

	local randSong = um:ReadChar()

	if ( !IsValid( LocalPlayer() ) ) then return end

	LocalPlayer().WaitingForPlayers:Stop() // just in case

	if ( LocalPlayer().WaitingForInfection != nil ) then
		LocalPlayer().WaitingForInfection:Stop()
		LocalPlayer().WaitingForInfection = nil
	end

	if ( !game.GetWorld().Started ) then
		LocalPlayer().Stinger:PlayEx( 1, 100 )

		LocalPlayer().RoundMusic = CreateSound( LocalPlayer(), RoundMusic .. tostring( randSong ) .. ".mp3" )
		LocalPlayer().RoundMusic:PlayEx( 1, 100 )

		game.GetWorld().Started = true
	end


	if ( infector != game.GetWorld() ) then
		if ( virusEnt == LocalPlayer() ) then
			LocalPlayer().IsThirdPerson = true
			--LocalPlayer().LocalInfected:PlayEx( 1, math.random( 170, 200 ) )
		end
	end

end

local function ClientFade( um )

	if ( !IsValid( LocalPlayer() ) ) then return end

	LocalPlayer().WaitingForPlayers:FadeOut( 2 )
end

local function ClientLastSurvivor( um )

	local randSong = um:ReadChar()

	if ( !IsValid( LocalPlayer() ) ) then return end

	LocalPlayer().WaitingForPlayers:Stop() // just in case

	if ( LocalPlayer().RoundMusic ) then

		LocalPlayer().RoundMusic:Stop()
		LocalPlayer().RoundMusic = nil

	end

	if ( LocalPlayer().LastSurvivor ) then

		LocalPlayer().LastSurvivor:Stop()
		LocalPlayer().LastSurvivor = nil

	end

	LocalPlayer().LastSurvivor = CreateSound( LocalPlayer(), LastAliveMusic .. tostring( randSong ) .. ".mp3" )
	LocalPlayer().LastSurvivor:PlayEx( 1, 100 )
end

local function ClientDmgTaken( um )

	// starting the health bar fade at 350 so it stays at full opacity for a bit
	GAMEMODE.DamageFade = 350

end

// this is to make sure when you spawn the sonic shotgun blue charge is undone
local function ClientSpawn( um )

	if !IsValid( LocalPlayer() ) then return end

	local viewModel = LocalPlayer():GetViewModel()
	if !IsValid( viewModel ) then return end

	viewModel:SetColor( Color( 255, 255, 255, 255 ) )

end

local function ClientLateMusic( um )

	local musicType = um:ReadChar()
	local musicNum = um:ReadChar()


	if ( musicType == MUSIC_WAITINGFORINFECTION ) then

		if ( LocalPlayer().WaitingForInfection ) then
			LocalPlayer().WaitingForInfection:Stop()
			LocalPlayer().WaitingForInfection = nil
		end

		LocalPlayer().WaitingForInfection = CreateSound( LocalPlayer(), WaitingForInfectionMusic .. math.random( 1, 8 ) .. ".mp3" )
		LocalPlayer().WaitingForInfection:PlayEx( 1, 100 )

	elseif ( musicType == MUSIC_INTERMISSION ) then

		LocalPlayer().VirusWin:Stop()
		LocalPlayer().SurvivorsWin:Stop()

		if ( musicNum == 1 ) then
			LocalPlayer().VirusWin:PlayEx( 1, 100 )
		else
			LocalPlayer().SurvivorsWin:PlayEx( 1, 100 )
		end

	end

end

usermessage.Hook( "StartRound", ClientStartRound )
usermessage.Hook( "EndRound", ClientEndRound )
usermessage.Hook( "Infect", ClientInfected )
usermessage.Hook( "FadeWaiting", ClientFade )
usermessage.Hook( "LastSurvivor", ClientLastSurvivor )
usermessage.Hook( "DmgTaken", ClientDmgTaken )
usermessage.Hook( "Spawn", ClientSpawn )
usermessage.Hook( "LateMusic", ClientLateMusic )

function HudMessage( msg, seconds, font, ignoreY, color )

	local VguiMsg = vgui.Create( "virus_HudMessage")

	VguiMsg:SetText( msg, font, color )
	VguiMsg.StayTime = seconds
	VguiMsg.IgnoreY = ignoreY or false
	VguiMsg:SetVisible( true )

	Msg( msg .. "\n")
end

//Weapon Fix
hook.Add("PostPlayerDraw", "CSSWeaponFix", function(v)
	local wep = v:GetActiveWeapon()
	if !IsValid(wep) then return end

	local hbone = wep:LookupBone("ValveBiped.Bip01_R_Hand")
	if !hbone then
		local hand = v:LookupBone("ValveBiped.Bip01_R_Hand")
		if hand then

			local pos, ang = v:GetBonePosition(hand)

			ang:RotateAroundAxis(ang:Forward(), 180)

			if wep:GetModel() == "models/weapons/w_pvp_neslg.mdl" then
				ang:RotateAroundAxis(ang:Up(), -90)
			end

			wep:SetRenderOrigin(pos)
			wep:SetRenderAngles(ang)

		end
	end
end)
