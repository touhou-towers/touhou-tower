include("shared.lua")
include("cl_message.lua")
include("cl_choose.lua")
include("cl_scoreboard.lua")
include("sh_payout.lua")
include("sh_player.lua")

local hud_lives = surface.GetTextureID( "gmod_tower/balls/hud_main_lives" )
local hud_bananas = surface.GetTextureID( "gmod_tower/balls/hud_main_bananas" )
local hud_timer = surface.GetTextureID( "gmod_tower/balls/hud_main_timer" )

local hud_icon_clock = surface.GetTextureID( "gmod_tower/balls/hud_icon_clock" )
local hud_icon_banana = surface.GetTextureID( "gmod_tower/balls/hud_icon_banana" )
local hud_icon_antlion = surface.GetTextureID( "gmod_tower/balls/hud_icon_antlion" )

local OUTLINE_COLOR = Color( 166, 117, 80 )

surface.CreateFont( "BallMessage", { font = "Bebas Neue", size = 48, weight = 200 } )
surface.CreateFont( "BallMessageCaption", { font = "Bebas Neue", size = 26, weight = 200 } )
surface.CreateFont( "BallPlayerName", { font = "Coolvetica", size = 32, weight = 500 } )
surface.CreateFont( "BallFont", { font = "Coolvetica", size = 48, weight = 200 } )

function GM:ChatBubbleOverride(ply)
	local ball = ply:GetBall()

	if ply:Team() == TEAM_PLAYERS && IsValid(ball) && ball:GetOwner() == ply then
		return ball:GetPos() + Vector(0, 0, 64)
	end

	return ply:EyePos()
end

function GM:OverrideHatEntity(ply)
	local ball = ply:GetBall()

	if ply:Team() == TEAM_PLAYERS && IsValid(ball) && ball:GetOwner() == ply then
		return ball.PlayerModel
	end
end

// Speed HUD
local lastSpeed = 0
local antlionRot = 0

// Banana HUD
local bananas = 0
local lastBanana = 0
local bananaTime = 0
local bananaRot = 0
local bananaSize = 0
local curRot = 0

// Timer HUD
local timerSize = 0

function GM:HUDPaint()
	local lives, speed = 0, 0
	if IsValid(LocalPlayer()) then
		lives = LocalPlayer():Deaths()
		bananas = LocalPlayer():Frags()
	end

	local state = GetState()
	local endtime = GetTime()

	local timeleft = endtime - CurTime()
	local timeformat = string.FormattedTime(timeleft, "%02i:%02i")

	local buffer = ""
	local ball = LocalPlayer():GetBall()
	local team = LocalPlayer():Team()

	if state == STATUS_WAITING then
		buffer = "WAITING FOR PLAYERS"
	elseif state == STATUS_PLAYING then
		if IsValid(LocalPlayer()) then
			if IsValid(ball) && ball:GetClass() == "player_ball" then
				if LocalPlayer():Team() == 2 || LocalPlayer():Team() == 3  then
					if IsValid(ball:GetOwner()) then
						buffer = "SPECTATING " .. tostring(ball:GetOwner():Name())
					end
				end
			else
				if LocalPlayer():Team() == 2 then
					buffer = "YOU ARE DEAD"
				elseif LocalPlayer():Team() == 3 then
					buffer = "SPECTATING"
				end
			end
		end
	--[[elseif state == STATUS_INTERMISSION then
		buffer = "INTERMISSION"]]
	end

	if state != STATUS_INTERMISSION || state != STATUS_INTERMISSION then
		surface.SetDrawColor( 255, 255, 255, 255 )

		if state != STATUS_WAITING then
			// Lives BG
			local livesX, livesY = 12, 12
			surface.SetTexture( hud_lives )
			surface.DrawTexturedRect( livesX, livesY, 256, 128 )
			// Lives Icon
			if LocalPlayer():Alive() && LocalPlayer():Team() == TEAM_PLAYERS then
				lastSpeed = speed
				if LocalPlayer().myspeed == nil then
					speed = 0
				else
					speed = LocalPlayer().myspeed
				end
				local changeSpeed = math.floor( ( lastSpeed - speed ) )
				if changeSpeed < -9 then
					changeSpeed = changeSpeed * .009 // yay magic numbers!! this is to lower the speed for rotation
					antlionRot = antlionRot + changeSpeed
				end

				surface.SetTexture( hud_icon_antlion )
				surface.DrawTexturedRectRotated( livesX + 51, livesY + 52, 128, 128, antlionRot )
			end

			// Banana BG
			local bananaX, bananaY = ScrW() - 268, 12
			surface.SetTexture( hud_bananas )
			surface.DrawTexturedRect( bananaX, bananaY, 256, 128 )

			// Banana Icon
			if lastBanana != bananas then // check bananas for animation
				curRot = bananaRot
				bananaTime = CurTime() + 1
				lastBanana = bananas
			end

			if CurTime() > bananaTime then
				bananaRot = math.Approach( bananaRot, 0, .09 ) // halt animation
				bananaSize = math.Approach( bananaSize, 0, .09 ) // halt animation
			else
				bananaRot = curRot + ( 10 * math.sin( CurTime() * 5 ) ) // animate!
				bananaSize = 30 * math.sin( CurTime() * 5 ) // animate!
			end

			surface.SetTexture( hud_icon_banana )
			surface.DrawTexturedRectRotated( ScrW() - 63, bananaY + 52, 128 + ( bananaSize * 2 ), 128 + ( bananaSize * 2 ), bananaRot )

			draw.SimpleTextOutlined( lives, "BallFont", 150, 95, Color( 255, 255, 255, 255), 1, 1, 2, OUTLINE_COLOR )
			draw.SimpleTextOutlined( bananas, "BallFont", ScrW() - 180, 95, Color( 255, 255, 255, 255), 1, 1, 2, OUTLINE_COLOR )
		end

		if timeleft >= 0 then

			// Timer BG
			local timerX, timerY = (ScrW() / 2) - 128, 10
			surface.SetTexture( hud_timer )
			surface.DrawTexturedRect( timerX, timerY, 256, 128 )

			// Timer Icon
			local sway = 6 * math.sin( CurTime() * 2 )
			local color = Color( 255, 255, 255, 255 )

			if timeleft <= 10 then
				color = Color( 255, 0, 0, 255 )
				timerSize = math.abs( 15 * math.sin( CurTime() * ( timeleft/60 * 2 ) ) ) // animate!
			else
				timerSize = math.Approach( timerSize, 0, .09 ) // halt animation
			end

			surface.SetTexture( hud_icon_clock )
			surface.SetDrawColor( color.r, color.g, color.b, color.a )
			surface.DrawTexturedRectRotated( ScrW() / 2, timerY + 40, 128 + ( timerSize * 2 ), 128 + ( timerSize * 2 ), sway )


			// Text
			if timeleft <= 10 then
				draw.SimpleTextOutlined( timeformat, "BallFont", (ScrW() / 2), 105, Color( 255, 0, 0, 255 ), 1, 1, 2, Color( 255, 255, 255, 255 ) )
			else
				draw.SimpleTextOutlined( timeformat, "BallFont", (ScrW() / 2), 105, Color( 255, 255, 255, 255 ), 1, 1, 2, OUTLINE_COLOR )
			end
		end
	end

	if  state == STATUS_WAITING || state == STATUS_PLAYING && (LocalPlayer():Team() == 2 || LocalPlayer():Team() == 3) then
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect( 0, ScrH()/1.058, ScrW(), 60 )

		--surface.SetDrawColor( 255, 255, 255, 155 )
		--surface.DrawRect( 0, 0, ScrW(), 3 )

		draw.SimpleText( buffer, "BallMessage", ScrW() / 2, ScrH()/1.028, Color( 255, 255, 255, 255 ), 1, 1 )
	elseif state == STATUS_PLAYING || state == STATUS_INTERMISSION then
		return
	end
end

local dist = 200
local wantdist = 200

function ZoomCam(ply, bind, pressed)
	local amt = 20

	local ball = ply:GetBall()

	if !IsValid(ball) then return end

	local distmin = ball:BoundingRadius()

	if dist == 0 then
		dist = distmin * 2
		wantdist = dist
	end

	if bind == "invnext" then
		wantdist = dist + amt
	elseif bind == "invprev" then
		wantdist = dist - amt
	end

	wantdist = math.Clamp(wantdist, distmin, 500)
end

function ZoomThink()
	dist = math.Approach(dist, wantdist, 500 * FrameTime())
end

hook.Add("PlayerBindPress", "ZoomCam", ZoomCam)
hook.Add("Think", "ZoomThink", ZoomThink)

local lastview = nil

function GM:CalcView( ply, origin, angles, fov )
	local ball = ply:GetBall()

	local view = {}
	view.origin 	= origin
	view.angles	= angles
	view.fov 	= fov

	if !IsValid(ball) then
		return lastview or view
	end

	local ballorigin = ball:GetPos()
	local maxview = ballorigin + angles:Forward() * -dist

	local trace = util.TraceLine({start=ballorigin, endpos = maxview, mask=MASK_OPAQUE, filter=GAMEMODE.FilteredEnts})

	if trace.Fraction < 1 then
		dist = dist * trace.Fraction
	end

	view.origin = ballorigin + angles:Forward() * -dist * 0.95

	lastview = view

	return view
end

function MouseEnable(ply, key)
	if key == IN_WALK then
		RestoreCursorPosition()
		gui.EnableScreenClicker(true)
	end
end

function MouseDisable(ply, key)
	if key == IN_WALK then
		RememberCursorPosition()
		gui.EnableScreenClicker(false)
	end
end

function MouseClick(mc)
	if mc == MOUSE_LEFT then
		local cursorvec = LocalPlayer():GetCursorAimVector()
		RunConsoleCommand("mouse_click", dist, cursorvec.x, cursorvec.y, cursorvec.z)
	end
end

hook.Add("KeyPress", "MouseEnable", MouseEnable)
hook.Add("KeyRelease", "MouseDisable", MouseDisable)
hook.Add("GUIMousePressed", "MouseClick", MouseClick)

local hide = {
	CHudHealth = true,
	CHudBattery = true,
	CHudAmmo = true,
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hide[ name ] ) then return false end
end )

function MusicSystem(Id)
	if Id == 1 then
		if timer.Exists("BGMUSIC") then
			return
		else
			if GetState() != 0 then
				RunConsoleCommand( "stopsound" )
			end
			timer.Create("BGMUSIC", 0.2, 0, function() surface.PlaySound(GetMusicSelection()) MusicLoop() end)
		end
	elseif Id == 2 then
		if timer.Exists("BGMUSIC") then
			RunConsoleCommand( "stopsound" )
			timer.Simple(0.2, function() timer.Remove("BGMUSIC") surface.PlaySound('GModTower/balls/bonusstage.mp3') end)
		end
	elseif Id == 3 then
		timer.Remove("BGMUSIC")
		timer.Simple(0.5, function() RunConsoleCommand( "stopsound" ) end)
	end
end

function MusicLoop()
	timer.Adjust("BGMUSIC", GetMusicDuration(), 0, function() surface.PlaySound(GetMusicSelection()) end)
end

net.Receive( "BGM", function( len, pl )
	local Id = net.ReadInt(3)
	MusicSystem(Id)
end )
ConVarPlayerFade = CreateClientConVar( "gmt_ballrace_fade", 255, true )

//hook.Add( "PostDrawTranslucentRenderables", "BallraceBall", function( bDrawingDepth, bDrawingSkybox )
//	local pf = ConVarPlayerFade:GetInt()
//
//	for _, ply in pairs( player.GetAll() ) do
//		if ply:Alive() and ply:Team() == TEAM_PLAYERS then // Leave dem spectators alone
//			if ply == LocalPlayer() then continue end // Skip ourselves
//			local ball = ply:GetBall()
//			if IsValid( ball ) then
//				if !LocalPlayer():Alive() or LocalPlayer():Team() != TEAM_PLAYERS then // Spectating
//					ball:SetRenderMode( RENDERMODE_TRANSALPHA )
//					ball:SetColor( Color( 255, 255, 255, 255 ) )
//					continue
//				end
//				local c = ply:GetColor() // GMod 13
//				local r,g,b,a = c.r, c.g, c.b, c.a
//				ball:SetRenderMode( RENDERMODE_TRANSALPHA )
//				ply:SetColorAll(Color(r, g, b, pf))
//				ball:SetColor( Color( 255, 255, 255, pf ) )
//			end
//			local c = ply:GetColor() // GMod 13
//				local r,g,b,a = c.r, c.g, c.b, c.a
//				ply:SetRenderMode( RENDERMODE_TRANSALPHA )
//			ply:SetColor(Color(r, g, b, 0))
//		end
//	end
//end )

hook.Add( "PostDrawTranslucentRenderables", "BallraceBall", function( bDrawingDepth, bDrawingSkybox )
	local pf = ConVarPlayerFade:GetInt()
	if pf < 1 then return end // Fk player fade man

	for _, ply in pairs( player.GetAll() ) do
		if ply == LocalPlayer() then return end // Skip ourselves
		if ply:Alive() and ply:Team() == TEAM_PLAYERS then // Leave dem spectators alone
			local ball = ply:GetBall()
			if IsValid( ball ) then
				if !LocalPlayer():Alive() or LocalPlayer():Team() != TEAM_PLAYERS then // Spectating
					ball:SetRenderMode( RENDERMODE_TRANSALPHA )
					ball:SetColor( Color( 255, 255, 255, 255 ) )
					return
				end
				local c = ply:GetColor() // GMod 13
				local r,g,b,a = c.r, c.g, c.b, c.a
				local distance = LocalPlayer():EyePos():Distance( ball:GetPos() )
				local opacity = math.Clamp( (distance / math.Clamp(pf, 1, 2048)) * 255, 0, 255 ) // Close enough
				ply:SetColorAll(Color(r, g, b, opacity))
				ball:SetRenderMode( RENDERMODE_TRANSALPHA )
				ball:SetColor( Color( 255, 255, 255, opacity ) )
			end
		end
		local c = ply:GetColor() // GMod 13
		local r,g,b,a = c.r, c.g, c.b, c.a
		ply:SetRenderMode( RENDERMODE_TRANSALPHA )
		ply:SetColor(Color(r, g, b, 0))
	end
end )
--[[hook.Add("GTowerScorePlayer", "AddKBananasDeaths", function()

	GtowerScoreBoard.Players:Add(
		"Bananas",
		5,
		75,
		function(ply)
			return ply:Frags()
		end,
		10
	)

	GtowerScoreBoard.Players:Add(
		"Lives",
		5,
		75,
		function(ply)
			return ply:Deaths()
		end,
		15
	)

end )]]
