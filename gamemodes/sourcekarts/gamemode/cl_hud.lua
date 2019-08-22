
-----------------------------------------------------
surface.CreateFont( "HudLarge", { font = "Bebas Neue", size = 180 } )

surface.CreateFont( "HudTime", { font = "Bebas Neue", size = 115 } )

surface.CreateFont( "HudNormal", { font = "Bebas Neue", size = 60 } )

surface.CreateFont( "HudSmall", { font = "Bebas Neue", size = 45 } )

surface.CreateFont( "HudTiny", { font = "Bebas Neue", size = 36 } )

surface.CreateFont( "HudTiny2", { font = "Bebas Neue", size = 24 } )



surface.CreateFont( "HudHuge", { font = "Days", size = 140 } )

surface.CreateFont( "HudMapname", { font = "Days", size = 100 } )

surface.CreateFont( "HudLargeAlt", { font = "Days", size = 80 } )

surface.CreateFont( "HudNormalAlt", { font = "Days", size = 60 } )

surface.CreateFont( "HudSmallAlt", { font = "Days", size = 32 } )

surface.CreateFont( "HudTinyAlt", { font = "Days", size = 24 } )



local HUDPosition = surface.GetTextureID( "gmod_tower/sourcekarts/hud_position" )

local HUDStripes = surface.GetTextureID( "gmod_tower/sourcekarts/hud_stripes" )

local HUDTime = surface.GetTextureID( "gmod_tower/sourcekarts/hud_time" )

local HUDWatch = surface.GetTextureID( "gmod_tower/sourcekarts/hud_watch" )

local HUDWatchHand = surface.GetTextureID( "gmod_tower/sourcekarts/hud_watchhand" )

local HUDBattleName = surface.GetTextureID( "gmod_tower/sourcekarts/hud_battlename" )

local HUDControls = surface.GetTextureID( "gmod_tower/sourcekarts/hud_controls" )



local HUDTextReady = surface.GetTextureID( "gmod_tower/sourcekarts/hud_text_ready" )

local HUDTextSet = surface.GetTextureID( "gmod_tower/sourcekarts/hud_text_set" )

local HUDTextGo = surface.GetTextureID( "gmod_tower/sourcekarts/hud_text_go" )

local HUDInterpTime = -1



local gradientDown = surface.GetTextureID("vgui/gradient_down")

local gradientUp = surface.GetTextureID("vgui/gradient_up")

local checkerMaterial = surface.GetTextureID("gmod_tower/sourcekarts/flag")

local fireMaterial = Material( "gmod_tower/sourcekarts/flames" )



//===============================================================


function GM:HUDPaint()



	// Ending state

	if self:GetState() == STATE_ENDING then
		surface.SetDrawColor( 0,0,0,240 )

		surface.DrawRect( 0, ScrH()/2 - 200, ScrW(), 200 )


		draw.SimpleShadowText( "GAME ENDED", "HudHuge", ScrW()/2, ScrH()/2 - 120, Color( 255, 255, 255 ), Color( 0, 0, 0, 220 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0, 0, 2 )

		draw.SimpleShadowText( "SENDING YOU ALL BACK TO THE LOBBY", "HudNormal", ScrW()/2, ScrH()/2 - 50, Color( 255, 255, 255 ), Color( 0, 0, 0, 220 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0, 0, 2 )

		return

	end



	// Battle intro

	if self:GetState() == STATE_BATTLEINTRO then

		self:DrawHUDBattleIntro()

		return

	end


	self:DrawHUDMain()
	self:DrawHUDBattle()



	self:DrawHUDCountdown()

	self:DrawHUDMessages()


	//self:DrawSpeedometer()

	//self:DrawRearView()


	// Active HUD

	if (LocalPlayer():Team() == TEAM_PLAYING && self:GetState() == STATE_PLAYING) then

		self:ActivateHUDElements()

		self:DrawInterpolatedHUDElements()
		self:DrawStreaks()
	else

		HUDInterpTime = -1

	end



	// Results

	if self:GetState() == STATE_NEXTTRACK || self:GetState() == STATE_NEXTBATTLE || self:GetState() == STATE_TOBATTLE || self:GetState() == STATE_BATTLEENDING || ( LocalPlayer():Team() == TEAM_FINISHED && self:GetState() != STATE_BATTLE ) then

		if self:GetState() != STATE_ENDING then

			self:DrawHUDResults()

		end

	end



	// Incoming!

	if LocalPlayer().Incoming then

		self:DrawHUDIncoming()

	end



	// Controls

	if self:GetState() == STATE_WAITING then

		local w, h = 1024 * .75, 512 * .75

		local x, y = ( ScrW() / 2 ) - ( w / 2 ), ScrH() - h - 120

		draw.RoundedBox( 8, x, y, w, h, Color( 255, 255, 255, 150 ) )



		surface.SetTexture( HUDControls )

		surface.SetDrawColor( 0, 0, 0, 100 )

		surface.DrawTexturedRect( x + 1, y + 1, w, h )

		surface.SetDrawColor( 255, 255, 255, 255 )

		surface.DrawTexturedRect( x, y, w, h )

	end



	// Map name

	self:DrawHUDMapName()



end



--Brings down interpolated elements

function GM:ActivateHUDElements()

	if HUDInterpTime != -1 then return end

	HUDInterpTime = RealTime()

end



function GM:DrawInterpolatedHUDElements()



	if HUDInterpTime == -1 then return end



	local dt = (RealTime() - HUDInterpTime)

	local x = 0

	local y = 0

	dt = math.min(dt, 4)



	if dt < 1 then

		x = 300 * math.min(1 - dt,1) ^ 2 + 300

		y = 60

	elseif dt < 2 then

		local dt2 = (dt - 1) * 3

		x = 300 * (1 - math.min(dt2,1) ^ 8)

		y = 60 * (1-dt2)



		if dt2 > 1 then

			local dt3 = math.min(dt2 - 1, 1)



			x = math.random(-10,10) * (1-dt3)

			y = math.random(-10,10) * (1-dt3)

		end

	end



	self:DrawHUDMaterials( x, y )

	self:DrawHUDPosition( x, y )

	self:DrawHUDLaps( x, y )



end



//===============================================================



function GM:DrawHUDMaterials( outx, outy )


	if self:GetState() != STATE_PLAYING then return end

	if LocalPlayer():Team() != TEAM_PLAYING then return end



	outx = outx or 0

	outy = outy or 0



	local color = Color( 7, 34, 48 )

	local rainbow = colorutil.Rainbow( 500 )

	local alpha = 230



	local kart = LocalPlayer():GetKart()

	local boost = false

	if IsValid( kart ) && kart.GetIsBoosting && kart:GetIsBoosting() then

		boost = true

	end



	// HUD Position

	local x, y, w, h = -outx, 60 - outy, 512, 256

	surface.SetDrawColor( color.r, color.g, color.b, alpha )

	surface.SetTexture( HUDPosition )

	surface.DrawTexturedRect( x, y, w, h )



	if boost then

		surface.SetDrawColor( rainbow.r, rainbow.g, rainbow.b, 100 )

		surface.DrawTexturedRect( x, y, w, h )

	end



	surface.SetDrawColor( 255, 255, 255, 255 )

	surface.SetTexture( HUDStripes )

	surface.DrawTexturedRect( x, y, w, h )



	// HUD Time

	w, h = w / 1.1, h / 1.1

	x = ScrW() - w - 10 + outx



	// HUD Minimap

	if IsValid( kart ) && miniMap:GetBool() then



		local zoom = .75

		local viewdir = Angle( 90, kart:GetAngles().y, 0 )



		local trace = util.TraceLine( { start = kart:GetPos(), endpos = kart:GetPos() + Vector( 0, 0, 20000 ), filter = ents.FindByClass( "sk_kart" ) } )



		local CamData = {}

		CamData.angles = viewdir

		CamData.origin = trace.HitPos

		CamData.w = 350

		CamData.h = 200

		CamData.x = x + 80

		CamData.y = y + CamData.h - 24

		CamData.drawviewmodel = false

		CamData.zfar = 100000

		CamData.ortho = true

		CamData.ortholeft = -ScrW()*zoom

		CamData.orthoright = ScrW()*zoom

		CamData.orthotop = -ScrH()*zoom

		CamData.orthobottom = ScrH()*zoom



		render.RenderView( CamData )



	end



	surface.SetDrawColor( color.r, color.g, color.b, alpha )

	surface.SetTexture( HUDTime )

	surface.DrawTexturedRect( x, y, w, h )



	if boost then

		surface.SetDrawColor( rainbow.r, rainbow.g, rainbow.b, 100 )

		surface.DrawTexturedRect( x, y, w, h )

	end



	surface.SetDrawColor( 255, 255, 255, 255 )

	surface.SetTexture( HUDWatch )

	surface.DrawTexturedRect( x, y, w, h )



	// Hand

	local perc = self:GetTimeElapsed(LocalPlayer():GetLapTime()) / LocalPlayer():GetBestLapTime()

	local rot = math.Fit( perc, 0.025, 1, 360, 0 )

	surface.SetDrawColor( 255, 255, 255, 255 )

	surface.SetTexture( HUDWatchHand )

	surface.DrawTexturedRectRotated( x + 88, y + 100, 128, 128, math.Clamp( rot, 0, 360 ) )



end



// ========================================================

// POSITION

// ========================================================


function NumberToNth( str )
	if str == 1 then return "st" end
	if str == 2 then return "nd" end
	if str == 3 then return "rd" end
	return "th"

end

function GM:DrawHUDPosition( outx, outy )



	if self:GetState() != STATE_PLAYING then return end

	if LocalPlayer():Team() != TEAM_PLAYING then return end



	outx = outx or 0

	outy = outy or 0



	local color = HSVToColor( 20 * LocalPlayer():GetPosition(), 1, 1 )



	local x, y = 256 - outx, 125 + 10 - outy

	local str = LocalPlayer():GetPosition()

	local nth = string.upper( NumberToNth( str, true ) )



	surface.SetFont( "HudLargeAlt" )

	local tw = surface.GetTextSize( nth )



	//draw.SimpleText( str, "HudHuge", x - tw - 5, y - 22, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )

	//draw.SimpleText( nth, "HudLargeAlt", x - 5, y + 18, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )

	draw.SimpleShadowText( str, "HudHuge", x - tw - 5, y + 50, color_white, black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2 )

	draw.SimpleShadowText( nth, "HudLargeAlt", x - 5, y + 40, color_white, black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2 )



	local max = "/" .. self.MaxLaps

	surface.SetFont( "HudLargeAlt" )

	local tw = surface.GetTextSize( max )



	//draw.SimpleText( LocalPlayer():GetLap(), "HudLargeAlt", x - tw - 6, y + 109, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )

	//draw.SimpleText( max, "HudNormalAlt", x - 24, y + 126, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )

	draw.SimpleShadowText( LocalPlayer():GetLap(), "HudLargeAlt", x - tw - 6, y + 129, color_white, black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2 )

	draw.SimpleShadowText( max, "HudNormalAlt", x - 24, y + 126, color_white, black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2 )



end



// ========================================================

// LAPS

// ========================================================



/*local function MonospacedTime( x, y, time )



	x = x - 180

	local t = string.Split( time, ":" )

	local wide = 95



	draw.SimpleShadowText( t[1], "HudNormal", x, y, color, black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2 )



	draw.SimpleShadowText( ":", "HudNormal", x + 15, y, color, black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2 )



	x = x + wide

	draw.SimpleShadowText( t[2], "HudNormal", x, y, color, black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2 )



	draw.SimpleShadowText( ":", "HudNormal", x + 15, y, color, black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2 )



	x = x + wide

	draw.SimpleShadowText( t[3], "HudNormal", x, y, color, black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2 )



end*/



function GM:DrawHUDLaps( outx, outy )

	if self:GetState() != STATE_PLAYING then return end



	outx = outx or 0

	outy = outy or 0



	local x, y = ScrW() - 50 + outx, 250 - outy

	local color = Color( 255, 255, 255 ) //HSVToColor( 75 * LocalPlayer():GetLap(), 1, 1 )

	local color2 = colorutil.Brighten( color, 1.25 )

	local black = colorutil.Brighten( color, .1, 250 )



	// Timer

	y = 110 - outy

	local ElapsedTime = string.FormattedTime( self:GetTimeElapsed(LocalPlayer():GetTotalTime()), "%02i:%02i:%02i" )

	draw.SimpleShadowText( ElapsedTime, "HudTime", x + 20, y, color, black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2 )



	if LocalPlayer():Team() == TEAM_PLAYING then



		y = 170 - outy

		local ElapsedTime = string.FormattedTime( self:GetTimeElapsed(LocalPlayer():GetLapTime()), "%02i:%02i:%02i" )

		draw.SimpleShadowText( "LAP", "HudSmallAlt", x - 150 + 8, y, color2, black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2 )

		draw.SimpleShadowText( ElapsedTime, "HudNormal", x + 8, y, color, black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2 )



		y = 215 - outy

		local ElapsedTime = string.FormattedTime( LocalPlayer():GetBestLapTime(), "%02i:%02i:%02i" )



		draw.SimpleShadowText( "BEST", "HudSmallAlt", x - 150, y, color2, black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2 )

		draw.SimpleShadowText( ElapsedTime, "HudNormal", x, y, color, black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2 )



	end



end



// ========================================================

// MAIN

// ========================================================



function GM:DrawHUDMain()


	// Title

	local title = nil

	local texttop = nil

	local textbottom = nil

	local time = math.floor( self:GetTimeLeft() )

	local color = colorutil.Rainbow( 50 )

	local y = ScrH()/3


	if LocalPlayer():Team() == TEAM_FINISHED then



		if self:GetState() == STATE_BATTLE then

			//title = "YOU HAVE DIED! WAITING FOR BATTLE TO END"

			//texttop = "YOU HAVE DIED"

			textbottom = "YOU DIED! WAITING FOR BATTLE TO END"

		else

			if self.FirstPlayerDelay then

				title = "WAITING FOR OTHERS " .. math.Round( self.FirstPlayerDelay - CurTime() )

				y = 150

			end



			textbottom = "YOU PLACED " .. LocalPlayer():GetPosition() .. NumberToNth( LocalPlayer():GetPosition() )



		end



	end



	if self:GetState() == STATE_WAITING then

		//title = "WAITING FOR PLAYERS " .. time

		texttop = "WAITING FOR PLAYERS"

		textbottom = time

	end



	if self:GetState() == STATE_NEXTBATTLE then

		//title = "NEXT BATTLE STARTING IN " .. time

		texttop = "NEXT BATTLE STARTING"

		textbottom = time

	end



	if self:GetState() == STATE_NEXTTRACK then

		//title = "NEXT TRACK STARTING IN " .. time

		texttop = "NEXT TRACK STARTING"

		textbottom = time

	end



	if self:GetState() == STATE_TOBATTLE then

		//title = "NEXT BATTLE STARTING IN " .. time

		texttop = "STARTING BATTLE"

		textbottom = time

	end



	if self:GetState() == STATE_BATTLEENDING then

		texttop = "BATTLE IS OVER"

		textbottom = time

	end


	local kart = LocalPlayer():GetKart()

	if LocalPlayer():Team() == TEAM_PLAYING and LocalPlayer():GetNWBool("Backwards") && IsValid( kart ) && kart:GetVelocity():Length() > 200 then

		title = "YOU ARE GOING BACKWARDS!"

		color = Color( 255, 0, 0, SinBetween( 0, 255, RealTime() * 15 ) )

	end



	if self.FirstPlayerDelay && LocalPlayer():Team() == TEAM_PLAYING then

		y = 150

		title = "RACE ENDING! " .. math.Round( self.FirstPlayerDelay - CurTime() )

	end



	if texttop || textbottom then

		self:DrawHUDBars( texttop, textbottom )

	end



	if title then

		TextRotated(

			title,

			"HudNormalAlt",

			Color( 0, 0, 0, math.Clamp( color.a - 20, 0, 255 ) ),

			ScrW()/2 + 2,

			y + 2,

			SinBetween( .85, 1, RealTime() * 3 ),

			SinBetween( .85, 1, RealTime() * 3 ),

			0,

			TEXT_ALIGN_CENTER,

			TEXT_ALIGN_CENTER

		)

		TextRotated(

			title,

			"HudNormalAlt",

			color,

			ScrW()/2,

			y,

			SinBetween( .85, 1, RealTime() * 3 ),

			SinBetween( .85, 1, RealTime() * 3 ),

			0,

			TEXT_ALIGN_CENTER,

			TEXT_ALIGN_CENTER

		)

	end



	// Timer

	/*if self:GetState() == STATE_PLAYING then



		local x, y = 200, 100

		//draw.SimpleTextOutlined( "RACE", "HudSmall", x - 100, y, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0 ) )

		//draw.SimpleTextOutlined( self:GetRound() .. "/" .. self.MaxRounds, "HudNormal", x, y, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0 ) )



		y = 150

		draw.SimpleTextOutlined( "TRACK", "HudSmall", x - 100, y, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0 ) )

		draw.SimpleTextOutlined( self:GetTrack() .. "/" .. self.MaxTracks, "HudNormal", x, y, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0 ) )



	end*/



end



function GM:DrawHUDIncoming()



	local color = Color( 255, 0, 0, 255 )

	surface.SetTexture( gradientUp )

	surface.SetDrawColor( color.r, color.g, color.b, SinBetween( 50, 150, RealTime() * 50 ) )

	surface.DrawTexturedRect( 0, ScrH() - 150, ScrW(), 150 )



	TextRotated(

		"INCOMING!",

		"HudNormal",

		Color( 0, 0, 0, 150 ),

		ScrW()/2+2,

		ScrH()-50+2,

		SinBetween( .85, 1, RealTime() * 30 ),

		SinBetween( .85, 1, RealTime() * 30 ),

		CosBetween( -5, 5, RealTime() * 20 ),

		TEXT_ALIGN_CENTER,

		TEXT_ALIGN_CENTER

	)

	TextRotated(

		"INCOMING!",

		"HudNormal",

		color,

		ScrW()/2,

		ScrH()-50,

		SinBetween( .85, 1, RealTime() * 30 ),

		SinBetween( .85, 1, RealTime() * 30 ),

		CosBetween( -5, 5, RealTime() * 20 ),

		TEXT_ALIGN_CENTER,

		TEXT_ALIGN_CENTER

	)



end



usermessage.Hook( "FirstPlayer", function( um )



	if um:ReadBool() then

		GAMEMODE.FirstPlayerDelay = CurTime() + GAMEMODE.FirstCountdown

	else

		GAMEMODE.FirstPlayerDelay = nil

	end



end )



// ========================================================

// READY TIMER

// ========================================================



--Assets

local mat_countdown = Material( "gmod_tower/sourcekarts/hud_countdown" )

local hasCountdown = file.Exists( "materials/gmod_tower/sourcekarts/hud_countdown.vtf", "GAME" )

local mat_white = Material( "vgui/white" )



--Countdown time

countdown_start = -1

countdown_started = false



--Info about animation frames

local frameinfo = {

	[1] = {

		color = Color(179,42,42),

		height = 305,

		scale = 1,

	},

	[2] = {

		color = Color(228,205,52),

		height = 426,

		scale = .8,

	},

	[3] = {

		color = Color(54,167,51),

		height = 473,

		scale = .8,

	}

}



--Draws a rotated texture with offset and scale parameters

local function textureRotatedOffset( x, y, width, height, sx, sy, cx, cy, r )



	--Rotate offset by degrees (r)

	local theta = -math.rad(r)

	local tx = math.cos(theta) * cx - math.sin(theta) * cy

	local ty = math.sin(theta) * cx + math.cos(theta) * cy



	--Draw texture at the new offset (scaled by sx, and sy)

	surface.DrawTexturedRectRotated( x + tx * sx, y + ty * sy, width * sx, height * sy, r )



end



local function renderFrame( num, dt, gscale )



	if dt < 0 then return end --Don't render if this frame hasn't started

	local info = frameinfo[num] --Info about this frame



	local height_mod = 512 - info.height --Center of the frame (from bottom)

	local add_scale = 0 --Scale up by this much

	local spin = 0 --Rotate the texture by this much

	local squeeze = 0 --Stretches out horizontally

	local flash = 0 --Flash the bars



	--Set default draw color

	surface.SetDrawColor( 255,255,255,255 )



	if dt < 1 then --Coming in



		surface.SetDrawColor( 255,255,255,255 * (dt) ) --Fade in by dt

		add_scale = ((1 - dt) * 10) ^ 3 --Scale down from 10x to 1x by (1-dt), taken to power of 3 for snappy effect

		spin = (1-dt) * 120 --Spin in from 120 degrees to 0



	elseif dt < 2 then --In for 1 / timescale seconds



		flash = math.max(1 - (dt - 1)*1.5, 0) --Flash the horizontal bars, dt is scaled up so it's faster



	elseif dt < 3 then --Zooming out



		squeeze = (dt - 2)^2 --Sqeeze the image out, taken to power of 2 for snappy effect

		surface.SetDrawColor( 255,255,255,255 * (1 - squeeze) ) --Fade out too



	else

		--Done, don't draw anything

		return

	end



	--On the 'go' frame, jiggle a bit.

	if dt > 1 and num == 3 then

		dt = math.min(dt - 1, 1)

		spin = spin + math.random(-5,5) * (1-dt) ^ 3

	end



	--Set material and set the animation frame (starts at 0)

	if hasCountdown then

		surface.SetMaterial( mat_countdown )

		mat_countdown:SetInt("$frame", num-1)



		--Draw the frame

		textureRotatedOffset(

			ScrW()/2, ScrH()/2, --x,y position

			1024, 512, --width, height of frame

			(info.scale + add_scale + squeeze * 2) * gscale, --x Scale

			(info.scale + add_scale - squeeze) * gscale, --y Scale

			0, (512 - info.height)/2, --x,y center

			spin --rotation

		)

	end



	--Draw the horizontal bars

	surface.SetMaterial( mat_white )

	surface.SetDrawColor(info.color.r, info.color.g, info.color.b, 255*flash) --Color from frame info

	surface.DrawRect(0,0,ScrW(),50)

	surface.DrawRect(0,ScrH() - 50,ScrW(),50)



end



function GM:DrawHUDCountdown()



	local time = math.ceil( self:GetTimeLeft() )



	if time == 3 && !countdown_started && self:GetState() == STATE_READY then

		countdown_start = RealTime()

		countdown_started = true

		surface.PlaySound("gmodtower/sourcekarts/effects/countdown.mp3") --music.PlaySong( MUSIC_COUNTDOWN )

	end



	--If countdown hasn't started, don't draw anything.

	if countdown_start == -1 then return end



	local gscale = .5 --Scale of all frames

	local dt = ( RealTime() - countdown_start ) --Time since countdown started

	local timescale = 2.5 --Timescale (maintains sync to each second)

	local duration = 4 * timescale --Duration of the countdown (realtime)



	dt = math.min(dt*timescale, duration) --Clamp input to duration



	--If the countdown is finished, don't draw anything

	if dt == duration then countdown_started = false return end



	--Fade out after 3 seconds in, taken to power of 3 for snappy effect

	local out = math.Clamp(dt - timescale*3, 0, 1) ^ 3



	--Automate height of horizontal bars

	local h = 50 * (1-out) * math.min(dt, 1)



	--Draw horizontal bars

	surface.SetMaterial( mat_white )

	surface.SetDrawColor(0, 0, 0, 255)

	surface.DrawRect(0,0,ScrW(),h)

	surface.DrawRect(0,ScrH() - h,ScrW(),h+5)



	--Render frame 1 at 0 seconds in

	renderFrame(1, dt, gscale)



	--Render frame 2 at 1 seconds in

	renderFrame(2, dt - timescale, gscale)



	--Render frame 3 at 2 seconds in

	renderFrame(3, dt - timescale*2, gscale)



	if dt - timescale < .5 then camera.Dist = 50

	elseif dt - timescale * 1.75 < 1 then camera.Dist = 25

	else camera.Dist = 0 end



end



function GM:DrawHUDMapName()


	if self:GetState() != STATE_READY then return end



	if string.find( LocalPlayer():GetCamera() or "", "Waiting" ) then



		--local mapData = Maps.GetMapData( game.GetMap() )


		mapData = {}

		mapData["gmt_sk_lifelessraceway01"] = { "Lifeless Raceway", "Lifeless" }
		mapData["gmt_sk_island01_fix"] = { "Drift Island", "Matt" }
		mapData["gmt_sk_rave"] = { "Rave", "Madmijk" }


		mapData.Name = mapData[game.GetMap()][1]
		mapData.Author = mapData[game.GetMap()][2]

		if !mapData then return end



		local name = mapData.Name



		surface.SetFont( "HudMapname" )

		local tw = surface.GetTextSize( name )



		local x, y = 120, ScrH() - 150



		draw.SimpleShadowText( name, "HudMapname", x, y, color_white, black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2 )

		draw.SimpleShadowText( "Track " .. self:GetTrack(), "HudSmallAlt", x + tw, y + 24, color_white, black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2 )

		draw.SimpleShadowText( "By " .. mapData.Author, "HudSmallAlt", x, y + 50, color_white, black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2 )



		surface.SetTexture( gradientUp )

		surface.SetDrawColor( 0, 0, 0, 255 )

		surface.DrawTexturedRect( 0, ScrH() - 150, ScrW(), 150 )



	end



end



// ========================================================

// SPEED STREAKS

// ========================================================



local streakMaterial = Material( "gmod_tower/sourcekarts/streak.vmt" )

local streaks = {}

local nextStreak = 0



local function DrawStreak( angle, x, y, length, dt, bright, boost )


	local cx, cy = ScrW() / 2, ScrH() / 2



	local rot = angle

	local a = math.deg( rot )



	x = x + math.cos( rot ) * length / 2

	y = y + math.sin( rot ) * length / 2



	if dt < .5 then

		dt = 1 - (dt * 2)

	end



	local color = Color( 255, 255, 255 )

	if boost then

		color = colorutil.Rainbow( 500 )

	end



	surface.SetMaterial( streakMaterial )



	surface.SetDrawColor( 0, 0, 0, 255 )

	surface.DrawTexturedRectRotated( x+1, y+1, length, length / 16, -a + 180 )



	surface.SetDrawColor( color.r, color.g, color.b, bright * ( 1-dt ) )

	surface.DrawTexturedRectRotated( x, y, length, length / 16, -a + 180 )



	--surface.DrawTexturedRectRotated( x, y, 10, 10, 0 )



end



function GM:DrawStreaks()



	local kart = LocalPlayer():GetKart()

	if !IsValid( kart ) then return end



	local speed = kart:GetVelocity():Length()

	local length = 500

	local t = CurTime()

	local width = ScrW()

	local height = ScrH()

	local amount = 2

	local maxalpha = 100



	if ( nextStreak < t && speed > 900 ) || kart:GetIsBoosting() then



		if kart:GetIsBoosting() then

			amount = 4

			delay = .005

			maxalpha = 255

		else

			delay = math.Fit( speed, 900, 1500, .025, .005 )

		end



		for n=1, amount do



			local lengthfactor = math.random(40,80) / 100

			table.insert(streaks, {

				time = t,

				angle = math.rad( math.random(0, 360) ),

				distFrac = lengthfactor,

				length = math.random( 1000, 1200 ) * lengthfactor,

				duration = .3,

				bright = math.random( maxalpha / 2, maxalpha ),

				speed = 600 + lengthfactor * 400,

			})



		end



		nextStreak = t + delay



	end



	local rm = {}

	for k,v in pairs(streaks) do



		if v.time + v.duration < t then



			table.insert( rm, v )



		else



			local dt = (t - v.time) / v.duration

			local d = dt * v.speed

			local px = width/2 + math.cos( v.angle ) * ( d + ( width / 2 ) * v.distFrac )

			local py = height/2 + math.sin( v.angle ) * ( d + ( height / 2 ) * v.distFrac )



			DrawStreak( v.angle, px, py, v.length, dt, v.bright, kart:GetIsBoosting() )



		end



	end



	while #rm > 0 do

		for i=1, #streaks do

			if streaks[i] == rm[1] then

				table.remove(streaks, i)

				break

			end

		end

		table.remove(rm, 1)

	end



end



// ========================================================

// BATTLE

// ========================================================



function GM:DrawHUDBattleIntro()



	surface.SetDrawColor( 0,0,0,240 )

	surface.DrawRect( 0, ScrH()/2 - 200, ScrW(), 200 )



	if self:GetState() == STATE_BATTLEINTRO then

		draw.SimpleShadowText( "BATTLE", "HudHuge", ScrW()/2, ScrH()/2 - 120, Color( 255, 255, 255 ), Color( 0, 0, 0, 220 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0, 0, 2 )

		draw.SimpleShadowText( "ELIMINATE ALL THE OTHER KARTS", "HudNormal", ScrW()/2, ScrH()/2 - 50, Color( 255, 255, 255 ), Color( 0, 0, 0, 220 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0, 0, 2 )

	end



end



function GM:DrawHUDBattle()



	if self:GetState() != STATE_BATTLE then return end



	local color = Color( 7, 34, 48, 230 )



	draw.SimpleShadowText( string.FormattedTime( self:GetTimeLeft(), "%02i:%02i" ), "HudNormalAlt", ScrW()/2, 80, Color( 255, 255, 255 ), Color( 0, 0, 0, 220 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0, 0, 2 )



	// HUD Round

	local x, y, w, h = 0, 60, 512, 256

	surface.SetDrawColor( color.r, color.g, color.b, color.a )

	surface.SetTexture( HUDTime )

	surface.DrawTexturedRect( ScrW() - w - 10, y, w, 128 )



	// Round/Players

	local x, y = ScrW() - 50, 90

	draw.SimpleShadowText( "ROUND", "HudSmallAlt", x - 150, y, Color( 255, 255, 255 ), Color( 0, 0, 0, 220 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2 )

	draw.SimpleShadowText( self:GetRound() .. "/" .. self.MaxRounds, "HudNormalAlt", x + 20, y - 5, Color( 255, 255, 255 ), Color( 0, 0, 0, 220 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2 )



	y = y + 45

	draw.SimpleShadowText( "COMBATANTS", "HudSmallAlt", x - 150, y, Color( 255, 255, 255 ), Color( 0, 0, 0, 220 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2 )

	draw.SimpleShadowText( #team.GetPlayers( TEAM_PLAYING ) .. "/" .. self:GetTotalPlayers(), "HudNormalAlt", x, y - 5, Color( 255, 255, 255 ), Color( 0, 0, 0, 220 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2 )





	// Show positions of other drivers

	local players = table.Copy( self:GetAllPlayers() )

	if #players == 0 then return end



	table.sort( players, function( a, b )

		return a:Deaths() < b:Deaths()

	end )



	// HUD Players

	y = 50

	for i, ply in pairs( players ) do



		if !IsValid( ply ) then continue end



		y = y + 28



		if ply:Team() == TEAM_FINISHED then

			surface.SetDrawColor( 150, color.g, color.b, color.a )

		else

			surface.SetDrawColor( color.r, color.g, color.b, color.a )

		end



		surface.SetTexture( HUDBattleName )

		surface.DrawTexturedRect( 0, y - 15, 512, 36 )



		// On HUD

		local nameoff = 5

		draw.SimpleShadowText( ply:Name(), "HudTinyAlt", 10, y - nameoff, Color( 255, 255, 255 ), Color( 0, 0, 0, 220 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2 )



		// Draw lives

		surface.SetFont( "HudTinyAlt" )

		local tw, th = surface.GetTextSize( ply:Name() )



		if ply:Team() == TEAM_FINISHED then

			draw.SimpleShadowText( "DEAD", "HudTinyAlt", tw + 25, y - nameoff, Color( 200, color.g, color.b, color.a ), Color( 0, 0, 0, 50 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2 )

		else



			local amt = GAMEMODE.MaxLives - ply:Deaths()

			local color = HSVToColor( 35 * amt, 1, 1 )

			for i=1, amt do

				draw.SimpleShadowText( "•", "KartPlayerName", tw + ( i * 25 ) - 10, y - nameoff - 2, color, Color( 0, 0, 0, 50 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2 )

			end

		end



		// In 3D space

		/*if ply == LocalPlayer() || ply.Ghost then continue end

		local pos = ( ent:GetPos() ):ToScreen()

		local dist = LocalPlayer():GetPos():Distance( ent:GetPos() )

		local alpha = math.Fit( dist, 1024, 2048, 0, 1 )



		if pos.visible then



			local x, y = pos.x, pos.y

			local size = math.Clamp( dist / 64, 0, 64 )



			cam.Start2D()

				draw.SimpleShadowText( "•", "HudSmallAlt", x - (size/2), y - (size/2), Color( 255, 255, 255, 255 * alpha ), Color( 0, 0, 0, 50 * alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2 )

			cam.End2D()



		end*/



	end



end



// ========================================================

// HUD MESSAGES

// ========================================================



local HUDMessages = {}

local HUDMessageTime = 2

function GM:DrawHUDMessages()



	for id, message in ipairs( HUDMessages ) do



		if !message then continue end



		local dt = ( message.Time - RealTime() )

		if dt <= 0 then table.remove( HUDMessages, id ) continue end



		// Get position

		local x = ( ScrW() / 2 ) + ( message.OffsetX or 0 )

		local y = ( ScrH() / 2 ) - 300 + ( 150 * dt ) + ( message.ID * 45 )



		// Draw

		message.Color.a = 255 * dt

		draw.WaveyText( message.Text, "HudSmall", x, y, message.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 10, wavelength, frequency)



	end



end



function GM:InsertHUDMessage( text, color )



	local message = {

		Text 	= text or "",

		Time 	= RealTime() + HUDMessageTime,

		Color 	= color or Color( 255, 255, 255, 255 ),

		OffsetX = math.random( -200, 200 ),

		ID 		= #HUDMessages + 1,

	}



	table.insert( HUDMessages, message )



end



/*usermessage.Hook( "HUDMessage", function( um )



	local text 	= um:ReadString()

	GAMEMODE:InsertHUDMessage( text )



end )
*/

net.Receive("HUDMessage",function()
	local text 	= net.ReadString()

	GAMEMODE:InsertHUDMessage( text )
end)


// ========================================================

// LETTER BOX

// ========================================================



function DrawChecker( alpha, x, y, black )



	/*surface.SetDrawColor( 255, 255, 255, alpha )

	surface.SetTexture( checkerMaterial )

	surface.DrawTexturedRect( x, y, ScrW(), 150 )*/



	local size = 32

	local amt = ScrW() / 3

	local maxrows = 9



	local col, row = 0, 0



	for i=1, amt do



		// Adjust column

		row = row + 1

		if row > maxrows then

			row, col = 1, col + 1

		end



		// Alt the colors

		if ( i % 2 ) == 0 then

			if black then

				surface.SetDrawColor( 0, 0, 0, alpha )

			else

				surface.SetDrawColor( 255, 255, 255, alpha )

			end

			surface.DrawRect( x + ( size ) + ( ( col - 1 ) * size ), y + ( row - 1 ) * size, size, size )

		else

			//surface.SetDrawColor( 0, 0, 0, alpha )

		end



	end



	return maxrows * size



end



/*local vecTranslate = Vector()

local vecScale = Vector(2,2,2)

local angRotate = Angle()

local function DrawCheckerMatrix( alpha, w, h )



	vecTranslate.x = SinBetween( 0, 150, RealTime() * 2 )

	vecTranslate.y = CosBetween( 0, 150, RealTime() * 2 )

	angRotate.y = 0

	vecScale.x = 2

	vecScale.y = 2



	local mat = Matrix()

	mat:Translate( vecTranslate )

	mat:Rotate( angRotate )

	mat:Scale( vecScale )

	mat:Translate( -vecTranslate )



	cam.PushModelMatrix(mat)

		DrawChecker( alpha, w, h )

	cam.PopModelMatrix()



end*/



local cy = 0

local function DrawBar( x, y, w, h, top )



	render.SetScissorRect( x, y, x + w, y + h, true )



		// BG

		surface.SetDrawColor( 0, 0, 0 )

		surface.DrawRect( x, y, w, h )



		// BG Gradient

		surface.SetDrawColor( 50, 50, 50 )

		if top then

			surface.SetTexture( gradientUp )

		else

			surface.SetTexture( gradientDown )

		end

		surface.DrawTexturedRect( x, y, w, h )



		// Checker

		cy = cy - .1

		local height = 0

		if top then

			height = DrawChecker( 10, x + SinBetween( -150, 0, RealTime() / 5 ), y + cy )

		else

			height = DrawChecker( 10, x + CosBetween( -150, 0, RealTime() / 5 ), y + cy )

		end

		if cy < -( height - h ) then cy = 0 end



		// Custom gradient

		if top then

			local p = 5

			for i=1, 150 do

				surface.SetDrawColor( i/p, i/p, i/p, math.Fit( i, 1, 150, 150, 1 ) )

				surface.DrawRect( x, y + h - ( i / p ), w, 1 )

			end

		else

			local p = 5

			for i=1, 150 do

				surface.SetDrawColor( i/p, i/p, i/p, math.Fit( i, 1, 150, 150, 1 ) )

				surface.DrawRect( x, y + ( i / p ), w, 1 )

			end

		end



		// Dividers

		surface.SetDrawColor( 255, 255, 255 )

		if top then

			surface.DrawRect( x, y + h-2, w, 1 )

		else

			surface.DrawRect( x, y+1, w, 1 )

		end



		surface.SetDrawColor( 50, 50, 50 )

		if top then

			surface.DrawRect( x, y + h-1, w, 1 )

		else

			surface.DrawRect( x, y, w, 1 )

		end



	render.SetScissorRect( 0, 0, 0, 0, false )



end



function GM:DrawHUDBars( texttop, textbottom )



	if texttop then

		DrawBar( 0, 0, ScrW(), 100, true )

		draw.SimpleShadowText( texttop, "HudLarge", ScrW() / 2, 50, Color( 255, 255, 255 ), Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4 )

	end



	if textbottom then

		DrawBar( 0, ScrH() - 100, ScrW(), 100, false )

		draw.SimpleShadowText( textbottom, "HudLarge", ScrW() / 2, ScrH() - 40, Color( 255, 255, 255 ), Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4 )

	end



end



// ========================================================

// RESULT LIST

// ========================================================



local function DrawResultBar( x, y, w, h, num, name, score, score2, score2title )



	render.SetScissorRect( x, y, x + w, y + h, true )



		// Color

		local color = HSVToColor( 25 * num, 1, 1 )

		color = Color( math.Clamp( color.r, 30, 180 ), math.Clamp( color.g, 30, 180 ), math.Clamp( color.b, 30, 180 ), 180 )

		surface.SetDrawColor( color )

		surface.DrawRect( x, y, w, h )



		// Checker

		/*cy = cy - .1

		local height = DrawChecker( 50, x + CosBetween( -150, 0, RealTime() ), y + cy, true )

		if cy < -( height - h ) then cy = 0 end*/



		// Custom gradient because materials fail me

		local p = 5

		for i=1, 25 do

			surface.SetDrawColor( i/p, i/p, i/p, math.Fit( i, 1, 25, 25, 1 ) )

			surface.DrawRect( x, y + h - ( i / p ), w, 1 )

		end

		for i=1, 25 do

			surface.SetDrawColor( i/p, i/p, i/p, math.Fit( i, 1, 25, 25, 1 ) )

			surface.DrawRect( x, y + ( i / p ), w, 1 )

		end



		// Borders

		local bcolor = colorutil.Brighten( color, 1.2 )

		surface.SetDrawColor( bcolor )

		surface.DrawRect( x, y + h-2, w, 1 )

		surface.DrawRect( x, y+1, w, 1 )



		surface.DrawRect( x+1, y, 1, h )

		surface.DrawRect( x+w-2, y, 1, h )



		surface.SetDrawColor( 50, 50, 50 )

		surface.DrawRect( x, y + h-1, w, 1 )

		surface.DrawRect( x, y, w, 1 )



		surface.DrawRect( x, y, 1, h )

		surface.DrawRect( x+w-1, y, 1, h )



		// Name

		draw.SimpleShadowText( name, "HudNormal", x + 8, y + (h/2) + 2, Color( 255, 255, 255 ), Color( 0, 0, 0, 220 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2 )



		// Score 2

		if score2 then



			surface.SetFont( "HudNormal" )

			local tw, th = surface.GetTextSize( score )



			surface.SetFont( "HudTiny" )

			local btw, bth = surface.GetTextSize( score2 )



			draw.SimpleShadowText( score2title, "HudTiny2", x + w - tw - 16 - ( btw / 2 ), y + 15, Color( 255, 255, 255 ), Color( 0, 0, 0, 220 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0, 0, 2 )

			draw.SimpleShadowText( score2, "HudTiny", x + w - tw - 16, y + h - 17, Color( 255, 255, 255 ), Color( 0, 0, 0, 220 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 0, 0, 2 )



		end



		// Score

		draw.SimpleShadowText( score, "HudNormal", x + w - 8, y + (h/2) + 2, Color( 255, 255, 255 ), Color( 0, 0, 0, 220 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 0, 0, 2 )



	render.SetScissorRect( 0, 0, 0, 0, false )



end



function GM:DrawHUDResults()



	local height = 52

	local w, h = 900, height

	local x, y = ( ScrW() / 2 ) - ( w / 2 ), 150

	local isbattle = self:GetState() == STATE_BATTLE || self:GetState() == STATE_NEXTBATTLE || self:GetState() == STATE_BATTLEENDING



	local players = player.GetAll() //table.Copy( self:GetAllPlayers() )



	// Sort

	if isbattle then

	table.sort( players, function( a, b )

		return a:Frags() > b:Frags()

	end )


	else

	table.sort( players, function( a, b )

		if a:GetPosition() == 0 || b:GetPosition() == 0 then

			return false

		end

		return a:GetPosition() < b:GetPosition()

	end )

	end



	// Display list

	for i, ply in ipairs( players ) do



		//if ply:Team() == TEAM_READY then continue end



		y = y + height + 6



		// Name

		local name = ply:Name()

		if ply:GetPosition() > 0 || isbattle then

			name = i .. ". " .. name

		end



		local score, score2, score2title



		// Race scores

		if !isbattle then



			// Time

			if ply:Team() == TEAM_FINISHED then



				local time --= self:GetTimeElapsed()

				if ply:GetTotalTime() > 0 then time = ( ply:GetNWFloat("FinishedTime") - ply:GetNWFloat("StartedTime") ) end



				score = string.FormattedTime( time, "%02i:%02i:%02i" )



			elseif GAMEMODE:GetState() == STATE_PLAYING then
				score = "DRIVING"
			else
				score = "DNF"

			end



			if ply:GetBestLapTime() > 0 then

				score2 = string.FormattedTime( ply:GetBestLapTime(), "%02i:%02i:%02i" )

				score2title = "BEST LAP"

			end



		// Battle scores

		else

			score = tostring(ply:Frags())

		end



		DrawResultBar( x, y, w, h, i, name, score, score2, score2title )



	end



end



// UNUSED DO TO RENDERING ISSUES

/*local function DrawRing( ang, r1, r2, d1, d2, col )



	local pos = Vector(0,0,0)

	local right = ang:Right()

	local up = ang:Up()

	local fwd = ang:Forward()

	local color = col or Color( 255, 255, 255, 255 )

	local ltvec = Vector(1,0,0)



	for i=0, 360, 12 do



		local lt = 1

		local r = math.rad( i )

		local si = math.sin( r )

		local co = math.cos( r )



		local v2 = pos + ((right * co) + (up * si)) * r1 + fwd * d1

		local v1 = pos + ((right * co) + (up * si)) * r2 + fwd * d2



		local bevel = (v2 - v1)



		bevel:Normalize()

		local face = bevel:Cross( right )



		if d2 == d1 then

			face = fwd

		end



		lt = math.abs( face:Dot( ltvec ) )



		mesh.Position( v1 )

		mesh.Color( color.r * lt, color.g * lt, color.b * lt, 255 )

		mesh.Normal( face )

		mesh.TexCoord( 0, 0, 0 )

		mesh.AdvanceVertex()



		mesh.Position( v2 )

		mesh.Color( color.r * lt, color.g * lt, color.b * lt, 255 )

		mesh.Normal( face )

		mesh.TexCoord( 0, 0, 0 )

		mesh.AdvanceVertex()



	end



end



local function DrawNeedle( ang, value, out, col )



	local n_angle = Angle(0,0,value)

	local right = ang:Right()

	local up = ang:Up()

	local fwd = ang:Forward()

	local color = col or Color( 255, 0, 0, 255 )

	local ltvec = Vector(1,0,0)

	local face = fwd

	local lt = 1



	right:Rotate( n_angle )

	up:Rotate( n_angle )



	local v1 = right * -2 - up * .05 + fwd * out

	local v2 = up * -.1 + fwd * out

	local v3 = up * .1 + fwd * out

	local v4 = right * -2 + up * .05 + fwd * out



	mesh.Position( v1 )

	mesh.Color( color.r * lt, color.g * lt, color.b * lt, 255 )

	mesh.Normal( face )

	mesh.TexCoord( 0, 0, 0 )

	mesh.AdvanceVertex()



	mesh.Position( v2 )

	mesh.Color( color.r * lt, color.g * lt, color.b * lt, 255 )

	mesh.Normal( face )

	mesh.TexCoord( 0, 0, 0 )

	mesh.AdvanceVertex()



	mesh.Position( v3 )

	mesh.Color( color.r * lt, color.g * lt, color.b * lt, 255 )

	mesh.Normal( face )

	mesh.TexCoord( 0, 0, 0 )

	mesh.AdvanceVertex()



	mesh.Position( v4 )

	mesh.Color( color.r * lt, color.g * lt, color.b * lt, 255 )

	mesh.Normal( face )

	mesh.TexCoord( 0, 0, 0 )

	mesh.AdvanceVertex()



end



local function CircleMesh( ang, r1, r2, d1, d2, col )



	mesh.Begin( MATERIAL_TRIANGLE_STRIP, 500 )



	pcall( DrawRing, ang, r1, r2, d1, d2, col )



	mesh.End()



end



local function NeedleMesh( ang, value, out, col )



	mesh.Begin( MATERIAL_QUADS, 1 )



	pcall( DrawNeedle, ang, value, out, col )



	mesh.End()



end



function GM:DrawSpeedometer()



	local kart = LocalPlayer():GetKart()

	if not kart then return end



	local kvel = kart:GetVelocity():Length()

	local pkvel = kvel / 4



	local size = 200

	local ang = Angle(180 - 10,10,0)



	ang.p = ang.p + math.random(-4,4) * (pkvel / 60)

	ang.y = ang.y + math.random(-4,4) * (pkvel / 60)



	surface.SetTexture(0)

	surface.DrawRect(0,0,1,1)

	--[[surface.DrawRect(

		ScrW()/2 - size/2,

		ScrH()/2 - size/2,

		size,

		size

	)]]



	local pos = Vector(-100,0,0)

	local angles = Angle(0,0,0)



	cam.Start3D( pos, angles, 4,

		ScrW() - size,

		ScrH() - size,

		size,

		size,

		0, 1000 )



		--[[mesh.Begin( MATERIAL_TRIANGLE_STRIP, 500 )



		pcall( DrawRing, ang, 2.0, 2.5, 0, 0.2 )

		pcall( DrawRing, ang, 2.0, 2.0, 0.2, 0.4 )



		mesh.End()]]



		CircleMesh( ang, 2.0, 0.0, 0.0, 0.0, Color(60,60,60,255) ) --backplate

		NeedleMesh( ang, pkvel - 30, 0.2, Color(255,0,0,255) ) --needle



		CircleMesh( ang, 0.25, 0.35, 0, 0.2, Color(80,80,80,150) ) --needle plate sides

		CircleMesh( ang, 0.25, 0.0, 0, 0, Color(80,80,80,150) ) --needle plate



		CircleMesh( ang, 2.0, 2.0, 0, 0.2, Color(80,80,80,150) ) --ring sides

		CircleMesh( ang, 2.0, 2.5, 0, 0.2, Color(80,80,80,150) ) --ring outer



	cam.End3D()





	--[[

	surface.DrawRect(

		ScrW() - size,

		ScrH() - size,

		size,

		size )

	]]



end



function GM:DrawRearView()



	local kart = LocalPlayer():GetKart()

	if not kart then return end



	local height = 20 --how high the mirror is

	local back = 40 --how far back it is



	local camera = {}

	camera.angles = kart:GetAngles()+Angle(0,180,0)

	camera.origin = kart:GetPos() + camera.angles:Up() * height + camera.angles:Forward() * back

	camera.x = ( ScrW() / 2 ) - ( ScrW() / 3 ) /2

	camera.y = 20

	camera.w = ScrW() / 3

	camera.h = ScrH() / 6

	render.RenderView( camera )



end*/
