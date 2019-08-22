
include( "shared.lua" )
include( "sh_payout.lua" )

include( "cl_deathnotice.lua" )
include( "cl_scoreboard.lua" )
include( "cl_post_events.lua" )

GTowerChat.YOffset = 400

local RoundAlert = false
local WalkTimer = 0
local VelSmooth = 0
local hacker = nil
local hackerangle = 0

local UseOldAmmo = CreateClientConVar( "gmt_pvp_oldammo", "0", true, false )

local hud_heart = surface.GetTextureID( "gmod_tower/pvpbattle/hud_heart" )
local hud_headphones = surface.GetTextureID( "gmod_tower/pvpbattle/hud_headphones" )
local hud_headphonesheart = surface.GetTextureID( "gmod_tower/pvpbattle/hud_headphonesheart" )
local hud_ammo = surface.GetTextureID( "gmod_tower/pvpbattle/hud_ammo" )
local hud_main = surface.GetTextureID( "gmod_tower/pvpbattle/hud_main" )
local hud_hacker = surface.GetTextureID( "gmod_tower/pvpbattle/hacker" )

surface.CreateFont( "PVPPrimary", { font = "TodaySHOP-MediumItalic", size = 55, weight = 200 } )
surface.CreateFont( "PVPPrimaryLeft", { font = "TodaySHOP-MediumItalic", size = 24, weight = 200 } )
surface.CreateFont( "PVPHeadPrimary", { font = "System", size = 55, weight = 200 } )
surface.CreateFont( "PVPTime", { font = "TodaySHOP-MediumItalic", size = 75, weight = 400 } )
surface.CreateFont( "PVPRound", { font = "TodaySHOP-MediumItalic", size = 35, weight = 400 } )
surface.CreateFont( "PVPRoundSubtitle", { font = "TodaySHOP-MediumItalic", size = 14, weight = 400 } )
surface.CreateFont( "DamageNote", { font = "TodaySHOP-MediumItalic", size = 28, weight = 200 } )
surface.CreateFont( "DamageNoteBig", { font = "TodaySHOP-MediumItalic", size = 48, weight = 200 } )

function GM:PlayerBindPress( ply, bind, pressed )
	if not pressed then return false end

	if ( bind == "+zoom" ) then
		return true
	end

	if(bind == "+menu") then
		RunConsoleCommand("lastinv")
		return true
	end
end

//apparently changing the volume to 0 will restart the song, so it really doesn't matter
net.Receive("ToggleMusic",function()

	if !LocalPlayer().Music then return end

	local bool = net.ReadBool()

	if bool then

		// woah woah, don't start the music when this is going
		local TimeLeft = GAMEMODE:GetTimeLeft()
		if TimeLeft > 0 && TimeLeft <= 16 then return end

		LocalPlayer().Music:PlayEx( 2, 100 )

	else

		LocalPlayer().Music:FadeOut( 1 )

	end

end )

function GM:GetRoundOverText()
	if game.GetWorld().PVPRoundCount >= self.MaxRoundsPerGame then
		return "Game ends in..."
	end

	return "Next Round In..."
end

function GM:HUDPaint()
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetTexture( hud_main )
	surface.DrawTexturedRect( ( ScrW() / 2 ) - 256, 0, 512, 128 )

	self:DrawHUDRound()
	self:DrawHUDTimer()
	self:DrawHUDWeapon()
	self:DrawHUDHealth()
	self:DrawHUDHacker()

	self:DrawDeathNotice( 0.032, 0.68 )

	self:DamageNotes()
end

function GM:DrawHUDRound()

	local color = Color( 255, 255, 255, 255 )
	draw.SimpleText( "ROUND", "PVPRoundSubtitle", ( ScrW() / 2 ) + 90, 12, color, 1, 1 )
	draw.SimpleText( math.Clamp( self:GetRoundCount() , 1 , self.MaxRoundsPerGame ) .. "/" .. self.MaxRoundsPerGame, "PVPRound", ( ScrW() / 2 ) + 90, 32, color, 1, 1 )

	/*local RoundOver = self:IsRoundOver()

	if RoundOver then
		draw.SimpleText( self:GetRoundOverText(), "RoundTimeTitle", ScrW() / 2, ( ScrH() - ScrH() ) + 15, Color( 150, 150, 150, 255 ), 1, 1 )
	else
		draw.SimpleText( "Round Time Remaining", "RoundTimeTitle", ScrW() / 2, ( ScrH() - ScrH() ) + 15, Color( 150, 150, 150, 255 ), 1, 1 )
	end*/

end

function GM:DrawHUDTimer()

	local TimeLeft = self:GetTimeLeft()
	local ElapsedTime = string.FormattedTime( TimeLeft, "%02i:%02i")

	if TimeLeft < 0 then TimeLeft = 0 end

	local color = Color( 255, 255, 255, 255 )
	if TimeLeft <= 16 then
		//color = Color( 255, 180, 180, 255 )
	end

	draw.SimpleText( ElapsedTime, "PVPTime", ( ScrW() / 2 ) - 40, 35, color, 1, 1 )

end

function GM:DrawHUDWeapon()

	if !LocalPlayer().GetActiveWeapon then return end

	if self:IsRoundOver() then return end

	local weapon = LocalPlayer():GetActiveWeapon()
	if !IsValid( weapon ) then return end

	local PrimaryAmmo = weapon:Clip1()
	if PrimaryAmmo == -1 then return end

	local PrimaryAmmoType = weapon:GetPrimaryAmmoType()
	local PrimaryAmmoLeft = LocalPlayer():GetAmmoCount( PrimaryAmmoType )

	if PrimaryAmmoType == 9 || PrimaryAmmoType == 11 then
		PrimaryAmmo = PrimaryAmmoLeft
		PrimaryAmmoLeft = 0
	end

	if UseOldAmmo:GetBool() then
		local size = 30
		local wobblsize = math.abs( 30 * math.sin( RealTime() * (10 - ( 4 ) ) ) )
		if PrimaryAmmo > 0 then
			surface.SetTexture(hud_ammo)
			surface.SetDrawColor(255,255,255,255)
			surface.DrawTexturedRect(  ( ScrW() - 120 ) - size, ( ScrH() - 120 ) - size, 75 + ( size * 2 ), 75 + ( size * 2 ) )
		else
			surface.SetTexture(hud_ammo)
			surface.SetDrawColor(255,0,0,255)
			surface.DrawTexturedRect(  ( ScrW() - 120 ) - wobblsize, ( ScrH() - 120 ) - wobblsize, 75 + ( wobblsize * 2 ), 75 + ( wobblsize * 2 ) )
		end
	elseif PrimaryAmmo > 0 then
		surface.SetDrawColor( 0, 0, 0, 250 )
		surface.DrawRect( ScrW() - 120, ScrH() - 122, 75, 50 )
		surface.DrawRect( ScrW() - 120, ScrH() - 70, 75, 20 )
	else
		local size = math.abs( 10 * math.sin( RealTime() * (10 - ( 4 ) ) ) )
		surface.SetDrawColor( 255, 0, 0, 255 )
		surface.DrawRect(  ( ScrW() - 120 ) - size, ( ScrH() - 120 ) - size, 75 + ( size * 2 ), 75 + ( size * 2 ) )
	end

	draw.SimpleText( PrimaryAmmo, "PVPPrimary", ScrW() - 84, ScrH() - 95, Color( 255, 255, 255, 255 ), 1, 1 )
	if PrimaryAmmoLeft > 0 then draw.SimpleText( PrimaryAmmoLeft, "PVPPrimaryLeft", ScrW() - 84, ScrH() - 59, Color( 255, 255, 255, 255 ), 1, 1 ) end

end

local lastHealth = 0
function GM:DrawHUDHealth()

	if LocalPlayer():Health() <= 0 then return end

	if GAMEMODE:IsRoundOver() then return end

	if LocalPlayer().Headphones then

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetTexture( hud_headphones )
		surface.DrawTexturedRect( 18, ScrH() - 148, 128, 128 )

		local size = math.abs( 15 * math.sin( RealTime() * (10 - (4 * LocalPlayer():Health()/100 ) ) ) )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetTexture( hud_headphonesheart )
		surface.DrawTexturedRect(  18 - size, ( ScrH() - 148 ) - size, 128 + ( size * 2 ), 128 + ( size * 2 ) )

		draw.SimpleText( LocalPlayer():Health(), "PVPHeadPrimary", 80, ScrH() - 90, Color( 255, 255, 255, 255 ), 1, 1 )

		return

	end

	local size = math.abs( 6 * math.sin( RealTime() * ( 10 - ( 8 * LocalPlayer():Health()/100 ) ) ) )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetTexture( hud_heart )
	surface.DrawTexturedRect(  16 - size, ( ScrH() - 148 ) - size, 128 + ( size * 2 ), 128 + ( size * 2 ) )

	lastHealth = math.Approach( lastHealth, LocalPlayer():Health(), 1 )
	draw.SimpleText( lastHealth, "PVPPrimary", 80, ScrH() - 85, Color( 255, 255, 255, 255 ), 1, 1 )

end

local hacker = nil
local hackerangle = 0
function GM:DrawHUDHacker()

	if hacker && CurTime() < hacker + 3 then
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetTexture( hud_hacker )
		local height = 256

		surface.DrawTexturedRectRotated((ScrW() / 2), 100 + height / 2, 512, height, hackerangle)
	end

end

--GtowerHUD = {}
function GetAmmoYPos()
    return 250
end

table.insert( GtowerHudToHide, "CHudHealth" )
table.insert( GtowerHudToHide, "CHudAmmo" )
table.insert( GtowerHudToHide, "CHudSecondaryAmmo" )
table.insert( GtowerHudToHide, "CHudBattery" )

function GM:HUDItemPickedUp()
	return false
end

function GM:HUDAmmoPickedUp()
	return false
end

function GM:HUDWeaponPickedUp()
	return false
end

function GM:AdjustMouseSensitivity( num )
	local ply = LocalPlayer()
	if !IsValid(ply) || !IsValid(ply:GetActiveWeapon()) then return end

	local weapon = ply:GetActiveWeapon()
	local zoomed = weapon.Zoomed
	local bIron = weapon:GetNetworkedBool( "Ironsights" )

	if zoomed or bIron then
		local fov = ply:GetFOV()
		return 0.1 * (fov / 90)
	else
		return -1
	end
end

function GM:CalcView( ply, origin, angle, fov )
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

	angle.roll = angle.roll + ang:Right():DotProduct( vel ) * 0.01

	if ( ply:GetGroundEntity() != NULL ) then
		angle.roll = angle.roll + math.sin( WalkTimer ) * VelSmooth * 0.001
		angle.pitch = angle.pitch + math.sin( WalkTimer * 0.5 ) * VelSmooth * 0.001
	end

	return self.BaseClass:CalcView( ply, origin, angle, fov )
end

net.Receive("PVPRound", function()
	local GameEnd = net.ReadBool()

	if GameEnd == true then
		LocalPlayer():ConCommand( "+showscores" )
	else
		LocalPlayer():ConCommand( "-showscores" )
		LocalPlayer():ConCommand( "r_cleardecals" )
		RoundAlert = false
		/*if LocalPlayer().RMusic then LocalPlayer().RMusic:Stop() end
		if LocalPlayer().Music then
			LocalPlayer().Music:Stop()
			LocalPlayer().Music:PlayEx( 0.5, 100)
		end*/
	end
end )

net.Receive( "hacker", function()
	local attack = net.ReadPlayer()

	if attack == LocalPlayer() then
		surface.PlaySound( Sound("GModTower/pvpbattle/Hacker.wav"))
		hacker = CurTime()
		hackerangle = math.random(10, 25)
	else
		surface.PlaySound( Sound("GModTower/pvpbattle/Hacked.wav"))
	end
end )


hook.Add("GTowerScorePlayer", "AddKills", function()

	GtowerScoreBoard.Players:Add(
		"Kills",
		5,
		75,
		function(ply)
			return ply:Frags()
		end,
		10
	)

end )

hook.Add("GTowerScorePlayer", "AddDeaths", function()

	GtowerScoreBoard.Players:Add(
		"Deaths",
		5,
		75,
		function(ply)
			return ply:Deaths()
		end,
		15
	)

end )
