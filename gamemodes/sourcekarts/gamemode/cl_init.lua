
include( "camsystem/cl_init.lua" )
include( "camsystem/shared.lua" )
include( "Catmull/shared.lua" )

include("gmt/camera/" .. game.GetMap() .. ".lua")
include("gmt/cl_particles.lua")
include("gmt/cl_post_events.lua")
include("gmt/cl_scoreboard.lua")
include("gmt/sh_payout.lua")

include("meta_player.lua")
include("meta_camera.lua")

include("shared.lua")
include("nwtranslator.lua")
include("cl_controls.lua")

include( "cl_hud.lua" )
include( "cl_huditem.lua" )

include("checkpoints/cl_init.lua")
include("checkpoints/shared.lua")

include("cl_debug3d.lua")

include("sh_items.lua")

CreateClientConVar( "sk_fun", "0", true, true )

local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
  ["CHudCrosshair"] = true
}

net.Receive("online_music", function()

	local ply = LocalPlayer()

	if IsValid(ply.OnlineMusic) then ply.OnlineMusic:Stop() end
	
	local URL = net.ReadString()
	
	sound.PlayURL( URL, "", function(s) 
		if IsValid(s) then
			ply.OnlineMusic = s
			ply.OnlineMusic:Play()
		end
	end)
	
end)

function GM:ChatBubbleOverride(ply)

	if !IsValid( ply ) then
		return false
	end

	local kart = ply:GetKart()

	if IsValid( kart ) then
		return kart:GetPos() + kart:GetUp() * 32
	end

	return false

end

function GM:OverrideHatEntity(ply)
	if LocalPlayer() == ply then
		return LocalPlayer():GetKart().PlayerModel
	end
	if IsValid( ply:GetKart() ) then
		return ply:GetKart().PlayerModel
	end

end


hook.Add( "HUDPaint", "ToyTownEffect", function()

	if !LocalPlayer():IsSlowed() then return end
	if !render.SupportsPixelShaders_2_0() then return end

    local NumPasses = 1
    local H = ScrH() * .4

    DrawToyTown( NumPasses, H )

end )

hook.Add( "Think", "LateJoinCameraDefault", function()

	if GAMEMODE:GetState() == STATE_WAITING then
		camsystem.LateJoinCamera = "Waiting"
		LocalPlayer():SetCamera( "Waiting", 0 )
	end

	if GAMEMODE:GetState() == STATE_PLAYING then
		camsystem.LateJoinCamera = "Playing"
	end

end )

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hide[ name ] ) then return false end

	-- Don't return anything here, it may break other addons that rely on this hook.
end )

usermessage.Hook( "ShowScores", function( um )

	local display = um:ReadBool()

	if display == true then
		RunConsoleCommand( "gmt_showscores", 1 )
	else
		RunConsoleCommand( "gmt_showscores" )
	end

end )

/*usermessage.Hook( "PlaySound", function( um )
	surface.PlaySound( "GModTower/sourcekarts/music/race_reveal2.mp3" )
	//surface.PlaySound( "GModTower/sourcekarts/music/Ridge Racer 7 - Jinbae's Ride.mp3" )
end )*/

--[[---------------------------------------------------------
    Name: TextRotated(text, font, color, x, y, xScale, yScale, angle, xAlign, yAlign)
    Desc: Draws rotated text at the given coordinates and degrees.
    	  This is most effectively used when the text is centered.
-----------------------------------------------------------]]
local DrawText = surface.DrawText
local SetTextPos = surface.SetTextPos
local PopModelMatrix = cam.PopModelMatrix
local PushModelMatrix = cam.PushModelMatrix

local matrix = Matrix()
local matrixAngle = Angle(0, 0, 0)
local matrixScale = Vector(0, 0, 0)
local matrixTranslation = Vector(0, 0, 0)

function TextRotated( text, font, color, x, y, xScale, yScale, angle, xAlign, yAlign )

	draw.SimpleText( text, font, x, y, color, xAlign, yAlign )

	--[[surface.SetTextColor( color )
	surface.SetFont( font )

	matrixAngle.y = angle
	matrix:SetAngles(matrixAngle)

	--Transform text for alignment only if needed
	if ( xAlign && xAlign ~= TEXT_ALIGN_LEFT ) || ( yAlign && yAlign ~= TEXT_ALIGN_TOP ) then

		--Text size
		local tw, th = surface.GetTextSize( text )
		local ox, oy = 0, 0
		local radians = math.rad(angle)

		--Calculate offset based on desired text alignment
		if xAlign == TEXT_ALIGN_CENTER then ox = -tw / 2 end
		if xAlign == TEXT_ALIGN_RIGHT then ox = -tw end

		if yAlign == TEXT_ALIGN_CENTER then oy = -th / 2 end
		if yAlign == TEXT_ALIGN_BOTTOM then oy = -th end

		--Rotate offset by 'radians'
		local tx = ox * math.cos(radians) - oy * math.sin(radians)
		local ty = ox * math.sin(radians) + oy * math.cos(radians)

		--Translate provided x,y by the scaled offset
		x = x + tx * xScale
		y = y + ty * yScale

	end


	matrixTranslation.x = x
	matrixTranslation.y = y
	matrix:SetTranslation(matrixTranslation)

	matrixScale.x = xScale
	matrixScale.y = yScale
	matrix:Scale(matrixScale)

	PushModelMatrix(matrix)
		SetTextPos(0, 0)
		DrawText(text)
	PopModelMatrix()]]

end

function GM:DrawWorldItem( ent, curdelay, removedelay, offset )

	if !removedelay then return end
	if !offset then offset = 20 end

	local pos = ent:LocalToWorld( Vector( -50, 0, offset ) )
	local ang = ent:GetAngles() + Angle( 90, 0, 0 )

	local time = curdelay - CurTime()
	local percent = time / removedelay

	local PowerupPolys = 16
	local PowerupPerc = percent * PowerupPolys
	local PowerupCircle = 8

	cam.Start3D2D( pos, ang, 0.25 )

		surface.SetTexture( 0 )
		surface.SetDrawColor( Color( math.random( 200, 255 ),
									 math.random( 200, 255 ),
									 math.random( 200, 255 ),
									 255 * percent ) )

		for i=1, PowerupPerc, 1 do
			surface.DrawPoly( draw.CircleComplex( i, 1.0, PowerupCircle, PowerupCircle + 10, PowerupPolys, 0 ) )
		end

		surface.DrawPoly(
			draw.CircleComplex(
				math.ceil( PowerupPerc ),
				PowerupPerc - math.floor( PowerupPerc ),
				PowerupCircle,
				PowerupCircle + 10,
				PowerupPolys,
				0
			)
		)

	cam.End3D2D()

end

hook.Add( "DrawKart", "DrawActiveItemProgress", function( self, model, ply )

	// Status of active power ups
	if ply == LocalPlayer() then
		local item = LocalPlayer():GetActiveItem()
		if item then
			GAMEMODE:DrawWorldItem( model, LocalPlayer().ItemUse + item.Length, item.Length )
		end
	end

end )

local devcvar = GetConVar("developer")
hook.Add( "DrawKart", "DrawDebug", function( self, model )

	// DEBUG
	if DEBUG && devcvar:GetBool() then

		//local color = render.GetLightColor( self:GetPos() )
		//local brightness = color:Length()

		local att = model:GetAttachment( model:LookupAttachment( "back" ) )
		local ang = self:GetAngles()
		local pos = att.Pos + ang:Forward() * -10 + ang:Up() * 5

		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )

		cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), .15 )

			/*draw.TextBackground( tostring( brightness ), "KartDebug", 0, 0, 8 )
			draw.DrawText( tostring( brightness ), "KartDebug", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

			local str = "OFF"
			if self:GetOwner():IsInDark() then str = "ON" end

			draw.DrawText( str, "KartDebug", 0, 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.DrawText( tostring( ang ), "KartDebug", 0, 30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )*/

			draw.DrawText( tostring( self:GetPos() ), "KartDebug", 0, 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.DrawText( tostring( self:GetAngles() ), "KartDebug", 0, 30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

			// Just messing around
			/*local total = #team.GetPlayers( TEAM_PLAYING ) + #team.GetPlayers( TEAM_FINISHED )
			draw.SimpleShadowText(  LocalPlayer():GetPosition() .. "/" .. total, "KartBackText", -75, 15 + 4, Color( 225, 225, 255, 200 ), Color( 0, 0, 0, 20 ) )
			draw.SimpleShadowText( LocalPlayer():GetLap() .. "/" .. GAMEMODE.MaxLaps, "KartBackText", 75, 15 + 4, Color( 225, 225, 255, 200 ), Color( 0, 0, 0, 20 ) )*/

		cam.End3D2D()

		/*local pos = self:GetPos() + self:GetAngles():Up() * self.FrameLift
		local color = Color( 255, 255, 200, math.random( 50, 255 ) )
		local scale = 30

		render.SetMaterial( Material( "sprites/powerup_effects" ) )
		render.DrawSprite( pos, scale, scale, color )

		Debug3D.DrawLine( self:GetPos(), self:GetPos() + self:GetAngles():Up() * 100, 2 )*/

	end

end )


-----------------------------------------------------
function SetModelScaleVector( ent, scale )

	if !IsValid( ent ) then return end

	local scalefix = Matrix()
	scalefix:Scale( scale )

	ent:EnableMatrix( "RenderMultiply", scalefix )

end

function DrawModelMaterial( ent, scale, material )

	// start stencil
	render.SetStencilEnable( true )

	// render the model normally, and into the stencil buffer
	render.ClearStencil()
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
	render.SetStencilWriteMask( 1 )
	render.SetStencilReferenceValue( 1 )

		// render model
		/*ent:SetModelScale( 1, 0 )
		ent:SetupBones()
		ent:DrawModel()*/

	// render the outline everywhere the model isn't
	render.SetStencilReferenceValue( 0 )
	render.SetStencilTestMask( 1 )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilPassOperation( STENCILOPERATION_ZERO )

	// render black model
	render.SuppressEngineLighting( true )
	render.MaterialOverride( material )

		// render model
		ent:SetModelScale( scale, 0 )
		ent:SetupBones()
		ent:DrawModel()

	// clear
	render.MaterialOverride()
	render.SuppressEngineLighting( false )

	// end stencil buffer
	render.SetStencilEnable( false )

end

local meta = FindMetaTable("Entity")

function meta:SetPlayerProperties( ply )

	if !IsValid( ply ) then return end

	if !self.GetPlayerColor then
		self.GetPlayerColor = function() return ply:GetPlayerColor2() end
	end

	self:SetBodygroup( ply:GetBodygroup(1), 1 )
	self:SetMaterial( ply:GetMaterial() )
	self:SetSkin( ply:GetSkin() or 1 )

	if self.MinecraftMat then
		self:SetMaterial( self.MinecraftMat )
	end

end

-----------------------------------------------------
AddPostEvent( "fadeon", function( mul, time )

	local layer = postman.NewColorLayer()
	layer.brightness = -2
	postman.FadeColorIn( "fade", layer, 1 )

end )

AddPostEvent( "fadeoff", function( mul, time )

	postman.ForceColorFade( "fade" )
	postman.FadeColorOut( "fade", .5 )

end )


AddPostEvent( "test2on", function( mul, time )

	-- Ripple overlay

end )

AddPostEvent( "test2off", function( mul, time )


end )

AddPostEvent( "fluxon", function( mul, time )

	layer = postman.NewBloomLayer()
	layer.sizex = 15.0
	layer.sizey = 0.0
	layer.multiply = 1.0
	layer.color = 0.0
	layer.passes = 1.0
	layer.darken = .9
	postman.FadeBloomIn( "fluxon", layer, 1 )

	local layer = postman.NewColorLayer()
	layer.color = 0.25
	postman.FadeColorIn( "fluxon", layer, 1 )

end )

AddPostEvent( "fluxoff", function( mul, time )

	postman.ForceColorFade( "fluxon" )
	postman.FadeColorOut( "fluxon", 1 )

	postman.ForceBloomFade( "fluxon" )
    postman.FadeBloomOut( "fluxon", 1 )

end )

AddPostEvent( "teleon", function( mul, time )

	local layer = postman.NewColorLayer()
	layer.contrast = 1
	layer.color = 2.0
	postman.FadeColorIn( "teleon", layer, 1 )

	layer = postman.NewBloomLayer()
	layer.sizex = 9.0
	layer.sizey = 9.0
	layer.multiply = 0.45
	layer.color = 1.0
	layer.passes = 0.0
	layer.darken = 0.0
	postman.FadeBloomIn( "teleon", layer, 1 )

	layer = postman.NewSharpenLayer()
	layer.contrast = .20
	layer.distance = 3
	postman.FadeSharpenIn( "teleon", layer, 1.5 )

	layer = postman.NewMaterialLayer()
	layer.material = "models/props_combine/portalball001_sheet"
	layer.alpha = 1
	layer.refract = 0.5
	postman.FadeMaterialIn( "teleon", layer, 3 )

end )

AddPostEvent( "teleoff", function( mul, time )

	postman.ForceColorFade( "teleon" )
	postman.FadeColorOut( "teleon", 1 )

	postman.ForceBloomFade( "teleon" )
    postman.FadeBloomOut( "teleon", 2 )

	postman.ForceSharpenFade( "teleon" )
    postman.FadeSharpenOut( "teleon", 1 )

    postman.ForceMaterialFade( "teleon" )
	postman.FadeMaterialOut( "teleon", .5 )

end )


-----------------------------------------------------
module( "Scoreboard.Customization", package.seeall )

// COLORS


// HEADER
HeaderTitle = "Source Karts"

// RANK SYSTEM
local function CalculateRanks()

	if NextCalcRank && NextCalcRank > CurTime() then
		return
	end

	local Players = player.GetAll()

	table.sort( Players, function( a, b )

		local aScore, bScore = a:Frags(), b:Frags()

		if aScore == bScore then
			return a:Deaths() < b:Deaths()
		end

		return aScore > bScore

	end )

	for k, ply in pairs( Players ) do
		ply.TrophyRank = k
	end

	NextCalcRank = CurTime() + 1

end

local Trophies =
{
	Scoreboard.PlayerList.MATERIALS.Trophy1,
	Scoreboard.PlayerList.MATERIALS.Trophy2,
	Scoreboard.PlayerList.MATERIALS.Trophy3
}

// PLAYER

PlayersSort = function( a, b )

	if GAMEMODE:IsBattle() then
		CalculateRanks()

		if !a.TrophyRank || !b.TrophyRank then
			return
		end

		return a.TrophyRank < b.TrophyRank
	end

	return string.lower( a:Name() ) < string.lower( b:Name() )

end


// Notification (above avatar)
PlayerNotificationIcon = function( ply )

	if not GAMEMODE:IsBattle() then

		if ply:Team() == TEAM_FINISHED then
			return Scoreboard.PlayerList.MATERIALS.Finish
		end

	else

		if ply:Frags() > 0 then

			CalculateRanks()

			if ply.TrophyRank then
				return Trophies[ ply.TrophyRank ]
			end

		end

	end

	return nil

end

// Subtitle (under name)
PlayerSubtitleText = function( ply )

	if ply:Team() == TEAM_FINISHED then
		if GAMEMODE:IsBattle() then
			return "ELIMINATED"
		else
			return "FINISHED " .. ply:GetPosition() .. NumberToNth( ply:GetPosition() )
		end
	end

end

// Action Box
PlayerActionBoxEnabled = true
PlayerActionBoxAlwaysShow = true
PlayerActionBoxWidth = 80
PlayerActionBoxRightPadding = 6
PlayerActionBoxBGAlpha = 80

hook.Add( "PlayerActionBoxPanel", "ActionBoxDefault", function( panel )

	Scoreboard.ActionBoxLabel(
		panel,
		nil,
		"LAP",
		function( ply )
			if ply:Team() == TEAM_PLAYING && !GAMEMODE:IsBattle() then
				return ply:GetLap()
			end
		end,
		nil
	)

	Scoreboard.ActionBoxLabel(
		panel,
		nil,
		"LAP TIME",
		function( ply )
			if ply:Team() == TEAM_PLAYING && !GAMEMODE:IsBattle() then
				return string.FormattedTime( GAMEMODE:GetTimeElapsed( ply:GetLapTime() ), "%02i:%02i:%02i" )
			end
		end,
		nil,
		95
	)

	Scoreboard.ActionBoxLabel(
		panel,
		nil,
		"BEST LAP",
		function( ply )
			if ply:Team() == TEAM_FINISHED && !GAMEMODE:IsBattle() then
				return string.FormattedTime( ply:GetBestLapTime() or 0, "%02i:%02i:%02i" )
			end
		end,
		nil
	)

	Scoreboard.ActionBoxLabel(
		panel,
		nil,
		"HITS",
		function( ply )
			if GAMEMODE:IsBattle() then
				return ply:Frags()
			end
		end,
		nil
	)

	Scoreboard.ActionBoxLabel(
		panel,
		nil,
		"LIVES",
		function( ply )
			if GAMEMODE:IsBattle() then
				return ( GAMEMODE.MaxLives - ply:Deaths() )
			end
		end,
		nil
	)

end )
