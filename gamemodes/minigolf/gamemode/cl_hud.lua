-----------------------------------------------------
surface.CreateFont( "HudSwing", { font = "FOP Title Style Font", size = 72 } )
surface.CreateFont( "HudHole", { font = "FOP Title Style Font", size = 46 } )
surface.CreateFont( "HudTitle", { font = "FOP Title Style Font", size = 32 } )
surface.CreateFont( "HudMessage", { font = "FOP Title Style Font", size = ScreenScale( 30 ) } )
surface.CreateFont( "HudNormal", { font = "FOP Title Style Font", size = ScreenScale( 20 ) } )
local HUDTopBar = surface.GetTextureID( "gmod_tower/minigolf/hud_main" )
//===============================================================
function GM:HUDPaint()
	if self:GetState() == STATE_INTERMISSION || self:GetState() == STATE_ENDING then
		//self:DrawPixel()
	end
	surface.SetDrawColor( 255, 255, 255, 255 )
	self:DrawHUDMessages()
	self:DrawHUDTimer()
	if self:GetState() == STATE_PLAYING || self:GetState() == STATE_INTERMISSION then
		if !ConVarDisplayHUD:GetBool() then return end
		self:DrawHUDMain()
		self:DrawHUDPower()
		self:DrawHUDPuttStatus()
		self:DrawHUDStrokeLimit()
	end
	if self:GetState() == STATE_PREVIEW then
		self:DrawHUDCourse()
	end 
	if self:IsPracticing() then
		self:DrawHUDPractice()
	end
end
function GM:DrawHUDTimer()
	local title = ""
	local showMili = false
	if self:GetState() == STATE_WAITING then 
		title = "WAITING FOR PLAYERS"
	end
	if self:GetState() == STATE_PREVIEW then
		//title = "PREVIEW " .. self:GetHoleName()
	end
	if self:GetState() == STATE_SETTINGS then
		title = "CUSTOMIZE"
	end
	if self:GetState() == STATE_INTERMISSION then
		//title = "INTERMISSION"
	end
	if self:GetState() == STATE_PLAYING && GAMEMODE:GetTimeLeft() <= 30 then
		if LocalPlayer():Team() == TEAM_PLAYING then
			title = "HURRY UP!"
		end
		showMili = true
	end
	if title != "" || showMili then
		local TimeLeft = GAMEMODE:GetTimeLeft()
		if TimeLeft < 0 then
			TimeLeft = 0
		end
		local ElapsedTime = string.FormattedTime( TimeLeft )
		local sElapsedTime = math.Round( ElapsedTime.s )
		if showMili then
			sElapsedTime = sElapsedTime .. "." .. tostring( math.Round( ElapsedTime.ms ) )
		end
		if self:GetState() == STATE_WAITING then
			local mElapsedTime = tostring( math.Round( ElapsedTime.m ) )
			
			if tonumber( mElapsedTime ) > 0 then
				if tonumber( sElapsedTime ) < 10 then
					sElapsedTime = "0" .. sElapsedTime
				end
				sElapsedTime = mElapsedTime .. ":" .. sElapsedTime
			end
		end
		local x, y = ScrW() / 2, 250
		local tx, ty = x, 310
		if showMili then
			x = x + math.random( -2, 2 )
			y = y + math.random( -2, 2 )
		end
		draw.SimpleTextOutlined( title, "HudNormal", x, y, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0 ) )
		draw.SimpleTextOutlined( sElapsedTime, "HudNormal", tx, ty, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0 ) )
	end
end
function GM:DrawHUDMain()
	local w, h = 512, 128
	local x = ( 0 - h ) - 10
	local y = ScrH() - h - 30
	local texty = 65
	surface.SetTexture( HUDTopBar )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( x, y, w, h )
	-- Swing
	draw.SimpleTextOutlined( math.Clamp( LocalPlayer():Swing() or 0, 0, StrokeLimit ), "HudSwing", w - h - 35, y + texty + 33, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 26, 86, 111 ) )
	-- Par
	draw.SimpleTextOutlined( self:GetPar() or 1, "HudHole", w - h - 168, y + texty + 8, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, nil, 2, Color( 0, 0, 0, 25 ) )
	-- Hole
	draw.SimpleTextOutlined( self:GetHole() or 0, "HudHole", w - h - 256, y + texty + 8, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, nil, 0, Color( 0, 0, 0, 25 ) )
end
function GM:DrawHUDCourse()
	local w, h = ScrW(), ScrH()
	local y = ScrH() - 30
	local texty = 65
	// Title
	draw.SimpleTextOutlined( self:GetHoleName(), "HudTitle", w / 2, y - texty - 8 - 128, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, nil, 2, Color( 0, 0, 0, 255 ) )
	// Info
	draw.SimpleTextOutlined( "HOLE " .. ( self:GetHole() or 0 ) .. " PAR " .. ( self:GetPar() or 1 ), "HudHole", w / 2, y - texty - 8 - 80, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, nil, 3, Color( 0, 0, 0, 255 ) )
end
function GM:DrawHUDStrokeLimit()
	local isNearLimit = ( LocalPlayer():Swing() >= ( StrokeLimit - 1 ) )
	if !isNearLimit || LocalPlayer():Team() == TEAM_FINISHED then return end
	local w, h = ScrW(), ScrH()
	local y = ScrH() - 30
	local texty = 65
	draw.SimpleTextOutlined( "LAST STROKE!", "HudTitle", ( w / 2 ) + math.random( -2, 2 ), ( y - texty - 8 - 128 ) + math.random( -2, 2 ), Color( 255, 15, 15 ), TEXT_ALIGN_CENTER, nil, 2, Color( 0, 0, 0, 255 ) )
end
function GM:DrawHUDPractice()
	if LocalPlayer():GetCamera() == "Playing" then return end
	local w, h = ScrW(), ScrH()
	local y = ScrH() - 30
	local texty = 65
	draw.SimpleTextOutlined( "CLICK TO PRACTICE PUTT", "HudTitle", w / 2, y - texty - 8 - 128, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, nil, 2, Color( 0, 0, 0, 255 ) )
end
local lastscore = nil
local lastscoreChange = RealTime()
function GM:DrawHUDPuttStatus()
	local w, h = ScrW(), ScrH()
	local y = ScrH() - 30
	local texty = 65
	if LocalPlayer():CanPutt() && LocalPlayer():Swing() >= 1 then
		local pardiff = LocalPlayer():GetParDiff( LocalPlayer():Swing() )
		local score = Scores[pardiff + 1]
		if score != lastscore then
			lastscore = score
			lastscoreChange = RealTime()
		end
		local time = RealTime() - lastscoreChange
		if score && time > 3 then
			draw.SimpleTextOutlined( "FOR " .. score, "HudTitle", w / 2, y - texty - 8 - 128, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, nil, 2, Color( 0, 0, 0, 255 ) )
		end
	end
end
function GM:DrawHUDPower()
	local y = 60
	local w, h = 325, 18
	local thickness = 3
	local offset = 40
	local percent = math.Round( ( Swing.power or 0 ) / MaxPower, 3 )
	local lastPowerPercent = math.Round( ( Swing.lastpower or 0 ) / MaxPower, 3 )
	//local colorperc = 1 - percent
	//local color = Color( 255, 255 * colorperc, 255 * colorperc )
	surface.SetDrawColor( 80, 80, 80, 150 )
	surface.DrawRect( offset, ScrH() - offset - h - y, w, h )
	surface.SetDrawColor( 255, 255, 255, 255 )
	draw.RectFillBorder( offset, ScrH() - offset - h - y, w, h, thickness, percent, Color( 31, 31, 31 ), Color( 255, 255, 255 ) )
	if Swing.lastpower > 0 then
		surface.SetDrawColor( 255, 0, 0, 255 )
		surface.DrawRect( (offset + (w*lastPowerPercent)), ScrH() - offset - h - y + thickness, 2, h - (thickness*2) )
	end
end
function GM:DrawPixel()
	render.CapturePixels()
	
	// Draw
	local function DrawScreenPixels( spacing, scale, offsetX, offsetY )
		render.CapturePixels()
		
		local spacing = spacing or 30
		local scale = scale or .3
		local size = spacing * scale
		for x=0, ScrW(), spacing do
			for y=0, ScrH(), spacing do
				local r, g, b = render.ReadPixel( x, y )
				
				surface.SetDrawColor( r, g, b, SinBetween( 10, 150, CurTime() * 8 ) )
				surface.DrawRect( offsetX + x*scale, offsetY + y*scale, size, size )
			end
		end
	end
	DrawScreenPixels( 15, 1, 0, 0 )
end
local HUDMessages = {}
local HUDMessageTime = 2
function GM:DrawHUDMessages()
	for id, message in ipairs( HUDMessages ) do
		if ( message.Time + HUDMessageTime ) < RealTime() then
			table.remove( HUDMessages, id )
			continue
		end
		local timer = RealTime() - message.Time
		if timer > HUDMessageTime then timer = HUDMessageTime end
		if ( message.Time + HUDMessageTime ) > RealTime() then
			timer = ( message.Time + HUDMessageTime ) - RealTime()
		end
		// Get text size
		surface.SetFont( "HudMessage" )
		
		local w, h = surface.GetTextSize( message.Text )
		// Get position
		local x = ( ScrW() / 2 ) + ( message.OffsetX or 0 )
		local y = ( ScrH() / 2 ) - ( h ) + ( 20 * timer ) + ( id * h )
		message.Color.a = 255 * timer
		draw.SimpleTextOutlined( message.Text, "HudMessage", x, y, message.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0, message.Color.a ) )
	end
end
usermessage.Hook( "HUDMessage", function( um )
	local text 	= um:ReadString()
	local message 		= {}
	message.Text 		= text
	message.Time 		= RealTime()
	message.Color 		= Color( 255, 255, 255, 255 )
	//message.OffsetX 		= math.random( -200, 200 )
	table.insert( HUDMessages, message )
end )

hidehud = {}
hidehud["CHudAmmo"] = true;
hidehud["CHudBattery"] = true;
hidehud["CHudCrosshair"] = true;
hidehud["CHudDamageIndicator"] = true;
hidehud["CHudDeathNotice"] = true;
hidehud["CHudGeiger"] = true;
hidehud["CHudHealth"] = true;

hook.Add( "HUDShouldDraw", "NOOOO", function( name )
	if hidehud[name] then
		return false
	end;
end)