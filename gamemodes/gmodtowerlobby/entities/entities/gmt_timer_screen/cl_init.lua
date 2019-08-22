
-----------------------------------------------------
include("shared.lua")
include("sh_error.lua")
include("sh_screens.lua")
include("cl_ctrlpanel.lua")

// 54.071 seconds
local light_0 = Material( "gmod_tower/countdown/light_0.png" )
local light_1 = Material( "gmod_tower/countdown/light_1.png" )
local decor = Material( "gmod_tower/countdown/7seg.png" )
local year = Material( "gmod_tower/countdown/2015.png" )
local bg = Material( "gmod_tower/countdown/bg.png" )
local plus = Material( "gmod_tower/countdown/plus.png" )
local colon = Material( "gmod_tower/countdown/colon.png" )
util.PrecacheSound( "gmodtower/lobby/countdown/finalcountdown.mp3" )

local mainFont2 = "Oswald"
surface.CreateFont( "GTowerTimerBold", { font = mainFont2, size = 128, weight = 900 } )
surface.CreateFont( "GTowerTimerHuge", { font = mainFont2, size = 128, weight = 400 } )
surface.CreateFont( "GTowerTimerLarge", { font = mainFont2, size = 64, weight = 400 } )
surface.CreateFont( "GTowerTimerMain", { font = mainFont2, size = 48, weight = 400 } )
surface.CreateFont( "GTowerTimerSmall", { font = mainFont2, size = 32, weight = 400 } )
surface.CreateFont( "GTowerTimerTiny", { font = mainFont2, size = 24, weight = 400 } )

// each bit is a segment
local Segments = {
	[0] = 126,
	[1] = 48,
	[2] = 109,
	[3] = 121,
	[4] = 51,
	[5] = 91,
	[6] = 95,
	[7] = 112,
	[8] = 127,
	[9] = 123,
	["t"] = 15,
	["o"] = 29,
	["f"] = 71,
	["a"] = 119,
	["r"] = 5,
	[""] = 0,
}
local Size = 17.105263157894736842105263157895
local Tilt = 76.973684210526315789473684210528
local LitColor = Color( 255, 255, 255 )
local UnlitColor = Color( 128, 128, 128 )
ENT.Last = {
	Time = 0,
	LastUnix = 0,
	lights = {},
	Power = false,
}
local sw, sh
ENT.Unique = 0
ENT.FalloffDelay = 0.07

function ENT:Initialize()

	self:SetupControlPanel()

end

--[[
2x3 light position matrix
[sx,shearx,tx]
[sheary,sy,ty]
]]
local lightMatrix = {
	{Size,	-Tilt / 18,	Size*3.5},
	{0,		Size,		-Size},
}

local lightSegments = {
	{ x = 1 , y = 1 , nx = 8 }, --top
	{ x = 10, y = 1 , ny = 8 }, --top-right
	{ x = 10, y = 10, ny = 8 }, --bottom-right
	{ x = 1 , y = 19, nx = 8 }, --bottom
	{ x = 1 , y = 10, ny = 8 }, --bottom-left
	{ x = 1 , y = 1 , ny = 8 }, --top-left
	{ x = 1 , y = 10, nx = 8 }, --center
}

function ENT:TransformLight( x, y, ox, oy )
	local lx = lightMatrix[1][1]*x + lightMatrix[1][2]*y + ox + lightMatrix[1][3]
	local ly = lightMatrix[2][1]*x + lightMatrix[2][2]*y + oy + lightMatrix[2][3]
	return lx, ly
end

function ENT:IsLightSectorLit( number, sector )
	local segment = Segments[ isnumber(number) and (number % 10) or number ]
	local segmentActive = bit.band( segment, 2 ^ (7 - sector) ) ~= 0
	local lit = self:GetPower() and ( segmentActive or self:IsPoweringOn() )
	return lit
end

function ENT:DrawLight( lx, ly, lit )
	self.Unique = self.Unique + 1
	local col = table.Copy( LitColor )

	surface.SetDrawColor( lit and LitColor or UnlitColor )
	surface.SetMaterial( lit and light_1 or light_0 )
	surface.DrawTexturedRect( lx, ly, Size, Size )
	if !lit and self.Last.lights[ self.Unique ] then
		local delay = self.FalloffDelay
		col.a = math.Clamp( self.Last.Time + delay - RealTime(), 0, delay ) * 255
		if col.a == 0 then self.Last.lights[ self.Unique ] = false end
		surface.SetDrawColor( col )
		surface.SetMaterial( light_1 )
		surface.DrawTexturedRect( lx, ly, Size, Size )
	end
	if lit and self.SET then self.Last.lights[ self.Unique ] = true end
end

function ENT:DrawNumber( number, x, y )

	if not isnumber( number ) and not isstring( number ) then
		return Tilt + Size * 9.5, Size * 19
	end

	local function light( x2, y2, lit )
		local lx, ly = self:TransformLight( x2, y2, x, y )
		self:DrawLight( lx, ly, lit )
	end
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( decor )
	surface.DrawTexturedRect( x - 13, y - Size/8, Tilt + Size * 11, Size * 19.3 )

	// display dimensions is 10 sectors wide and 19 sectors tall
	for k,v in pairs(lightSegments) do
		local lit = self:IsLightSectorLit( number, k )
		for i=1, (v.nx or v.ny) do light(
			v.nx and (i + v.x) or v.x,
			v.ny and (i + v.y) or v.y,
			lit )
		end
	end

end


function ENT:ProcessFinalCountdown( plus, remaining )
	if !plus and remaining <= 54 and !self.FinalCountdown and self:GetCeleb() then
		local music = CreateSound( LocalPlayer(), "gmodtower/lobby/countdown/finalcountdown.mp3" )
		music:Play()
		self.FinalCountdown = music
	elseif !self:GetCeleb() or plus and remaining >= 256 and self.FinalCountdown or !plus and remaining > 54 and self.FinalCountdown then
		if self.FinalCountdown then
			self.FinalCountdown:Stop()
			self.FinalCountdown = nil
		end
	end
end


sw, sh = ENT.DrawNumber(nil)
function ENT:Think()
	// do this in think so music plays no matter what

	if self:GetPower() != self.Last.Power then
		if !self:GetPower() then
			self.Last.LastUnix = os.time()
			self.Last.Time = RealTime()
		end
		self.Last.Power = self:GetPower()
	end

	self.Time = os.time()
	if self:GetPower() then
		if !self:GetTimerMode() then
			local Remaining
			if !self:GetRealTime() then
				/*
				local TargetTime, TargetTab = self:GetTimeTable()
				local Tgt = os.time( TargetTab )
				Remaining = Tgt - self.Time*/
				Remaining = self:GetRemaining()
			else
				local tab = os.date( '*t', self.Time )
				Remaining = tab.sec + tab.min * 60 + tab.hour * 60 * 60
			end
			local Plus = Remaining < 0
			Remaining = math.abs( Remaining )
			if self.Last.LastUnix != self.Time then
				self.Last.LastUnix = self.Time
				self.Last.Time = RealTime()
				self.SET = true
				if Remaining < 60 and !Plus then
					self:EmitSound( "gmodtower/misc/chat" .. ( self.Time % 2 == 0 and "1" or "2" ) .. ".wav", 70, 100 )
				end
			end
			self:ProcessFinalCountdown( Plus, Remaining )
		else
			local Remaining = self:GetRemaining()
			if self:GetTimerRunning() and Remaining != self.Last.LastUnix then
				self.Last.LastUnix = Remaining
				self.Last.Time = RealTime()
				self.SET = true
				if Remaining <= 10 and Remaining >= 0 then
					self:EmitSound( "gmodtower/misc/chat" .. ( Remaining % 2 == 0 and "1" or "2" ) .. ".wav", 70, 100 )
				end
			end
			self:ProcessFinalCountdown( Plus, Remaining )
		end
	end
end
local ScreenOrigin = Vector( 2.702465, 0, 84.452540 )
local WHITE = Color( 255, 255, 255 )
local GREY = Color( 30, 30, 30 )
local BLACK = Color( 0, 0, 0 )
local RED = Color( 255, 0, 0 )
function ENT:Draw()

	self:DrawModel()
	//local w, h = 408, 70
	local w, h = 178, 90
	//local w, h = 2040, 400
	local scale = 0.09
	local ow, oh = w, h
	w = w / scale
	h = h / scale

	local ang = self:GetAngles()
	local pos = self:LocalToWorld( ScreenOrigin )
	ang:RotateAroundAxis( ang:Up(), 90 )
	ang:RotateAroundAxis( ang:Forward(), 90 )
	pos = pos + self:GetRight() * ( w*scale ) / 2
	pos = pos + self:GetUp() * ( h*scale ) / 2
	self.Pos = pos
	self.Ang = self:GetAngles()
	if ( LocalPlayer():EyePos() - pos ):Dot( ang:Up() ) < 0 or LocalPlayer():EyePos():Distance( pos ) > 1800 then return end
	cam.Start3D2D( pos, ang, scale )

			self.Unique = 0
			draw.RoundedBox( 0, 0, 0, w, h, self:GetPower() and WHITE or BLACK )
			if self:GetIsNewYears() then
				surface.SetDrawColor( 0, 0, 0, 255 )
				surface.SetMaterial( bg )
				surface.DrawTexturedRect( 0, 500, w, 500 )
			end
				draw.RoundedBox( 0, 0, 0, w, 230 + sh, GREY )
			//draw.RoundedBox( 0, w / -128, h / -2, w / 64, h / 2, Color( 0, 0, 0 ) )
			surface.SetDrawColor( 255, 255, 255 )

			local Remaining
			local Plus
			if !self:GetTimerMode() then

				if self:GetRealTime() then
					local tab = os.date( '*t', self.Time )
					Remaining = tab.sec + tab.min * 60 + tab.hour * 60 * 60
				else
					local Target = self:GetRemaining()
					Plus = Target < 0
					Remaining = math.abs( Target )

				end
			else
				if self:GetTimerRunning() then
					Remaining = self:GetRemaining()
					Plus = Remaining < 0
					Remaining = math.abs( Remaining )
				else
					Remaining = math.floor( self:GetTimerLength() )
				end
			end

			local Time = {}
			Time.sec = Remaining % 60
			Time.min = math.floor( Remaining / 60 ) % 60
			Time.hour = math.floor( Remaining / 60 / 60 )
			local Extended
			local TooFar
			if Time.hour > 99 and !self:GetTimerMode() then // turn to weeks days and months
				Extended = true
				Time.sec = math.floor( Remaining / 60 / 60 / 24 % 7 )
				Time.min = math.floor( Remaining / 60 / 60 / 24 / 7 % 4.34812 )
				Time.hour = math.floor( Remaining / 60 / 60 / 24 / 7 / 4.34812 )
			end
			if Time.hour > 99 and self:GetTimerMode() then
				TooFar = true
			else
				TooFar = false
			end

			--print( tostring( TooFar ) )

			//PrintTable( Time )

			// hour center: 0.21463
			// min center:  0.53658
			// sec center:  0.84878

			local hcen = 350 / 2 + 50
			local hc = 0.21463 * w
			local mc = 0.53658 * w
			local sc = 0.84878 * w
			local w2, h2 = self:DrawNumber()
			local lit = Remaining % 2 == 0

			self:DrawNumber( TooFar and ( lit and "t" or "" ) or math.floor( Time.hour / 10 ), hc - w2 * 0.83, hcen - h2 / 2 )
			self:DrawNumber( TooFar and ( lit and "o" or "" ) or Time.hour, hc + w2 * 0.17, hcen - h2 / 2 )

			self:DrawNumber( TooFar and ( lit and "o" or "" ) or math.floor( Time.min / 10 ), mc - w2 * 0.83, hcen - h2 / 2 )
			self:DrawNumber( TooFar and ( lit and "f" or "" ) or Time.min, mc + w2 * 0.17, hcen - h2 / 2 )

			self:DrawNumber( TooFar and ( lit and "a" or "" ) or math.floor( Time.sec / 10 ), sc - w2 * 0.83, hcen - h2 / 2 )
			self:DrawNumber( TooFar and ( lit and "r" or "" ) or Time.sec, sc + w2 * 0.17, hcen - h2 / 2 )

			// colons
			// FROM CENTER .27143

			// c1top 	.40487
			// c1bottom	.38780

			// c2top	.71951
			// c2bottom .7

			// PLUS/MINUS CENTER
			// .06097

			local function light( lit, x, y )

				lit = self:GetPower() and ( lit or self:IsPoweringOn() )
				//print( self.Unique )
				x = x - Size / 2
				y = y - Size / 2
				self:DrawLight( x, y, lit )

			end
			surface.SetDrawColor( 255, 255, 255 )
			surface.SetMaterial( plus )
			surface.DrawTexturedRect( 68, 182, 105, 85 )
			surface.SetMaterial( colon )
			local cwr = 0.36049723756906077348066298342541
			local ch = sh * .31143 * 2
			local cw = ch * cwr * 1.1
			surface.DrawTexturedRect( 0.396 * w - cw / 2, hcen - sh * .31143, cw, ch )
			surface.DrawTexturedRect( 0.713 * w - cw / 2, hcen - sh * .31143, cw, ch )
			light( lit, w * .40787, hcen - sh * .27143 )
			light( lit, w * .38360, hcen + sh * .27143 )

			light( lit, w * .725, hcen - sh * .27143 )
			light( lit, w * .701, hcen + sh * .27143 )

			local cx, cy = w * 0.06097, hcen
			local Slope = h2 / w2

			for i = -2, 2 do
				if i != 0 then
					light( !self:GetRealTime() and Plus, cx - ( i - 0 ) / 18 * Tilt, cy + i * Size )
				end
				light( !self:GetRealTime(), cx + Size * i, cy )
			end
			if self:GetPower() then
				draw.DrawText( Extended and "MONTH" or "HOUR", "GTowerTimerHuge", hc, sh + 75, WHITE, TEXT_ALIGN_CENTER )
				draw.DrawText( Extended and "WEEK" or "MINUTE", "GTowerTimerHuge", mc, sh + 75, WHITE, TEXT_ALIGN_CENTER )
				draw.DrawText( Extended and "DAY" or "SECOND", "GTowerTimerHuge", sc, sh + 75, WHITE, TEXT_ALIGN_CENTER )
				if self:GetIsNewYears() then
					draw.SimpleText( Plus and "into" or "until", "GTowerTimerLarge", w / 2, h / 2 + 50, BLACK, TEXT_ALIGN_CENTER, nil )
					draw.SimpleTextOutlined( (os.date( "*t" ).year + 1), "GTowerTimerBold", w / 2, h / 2 + 150, WHITE, TEXT_ALIGN_CENTER, nil, 2, BLACK )
				else
					draw.SimpleText( self:GetTitle(), "GTowerTimerHuge", w / 2, h / 2 + 50, BLACK, TEXT_ALIGN_CENTER, nil )
					draw.SimpleText( self:GetDescription(), "GTowerTimerBold", w / 2, h / 2 + 220, BLACK, TEXT_ALIGN_CENTER, nil )

				end
			end
			//draw.DrawText( "2015", "GTowerTimerHuge", w / 2, h / 4 * 3, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )


		self.SET = nil

	cam.End3D2D()

end
