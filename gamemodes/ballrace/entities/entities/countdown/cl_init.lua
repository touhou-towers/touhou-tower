include('shared.lua')

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local FONT = "GTowerSkyMsg"
local SMALLFONT = "GTowerSkyMsgSmall"
surface.CreateFont( FONT, {
	font = "Oswald",
	size = 144,
	weight = 600,
	antialias = true,
	additive = false
} )
surface.CreateFont( SMALLFONT, {
	font = "Oswald",
	size = 65,
	weight = 600,
	antialias = true,
	additive = false
} )



function ENT:Initialize()
	self:SetModel( self.Model )

	self.NegativeX = 0
	self.PositiveY = 0
	self.TextWidth = 0
	self.TextHeight = 0
	self.StrText = ""
	self.IsTheater = false
	self.TColor = Color(255,255,255,255)
	self:DrawShadow( false )
	self.TimeLeft = "10"

	timer.Simple(0.1,function()

		timer.Create("DisplayCountdown",1,tonumber(self.StrText,10),function()

			if self.StrText != nil then
				self.TimeLeft = tonumber(self.StrText,10)
				self.StrText = self.TimeLeft - 1
				if tonumber(self.StrText,10) <= 3 then
					self.TColor = Color(255,25,25,255)
				end
			end

		end)

	end)

end

function ENT:Think()

	local Skin = tonumber( self:GetSkin() )

	if Skin != 0 then
		self:TextChanged( Skin )

		self.Think = EmptyFunction
	end

end

function ENT:TextChanged( id )

	surface.SetFont( FONT )

	if !self.Messages[ id ] then
		return
	end

	self.StrText = self.Messages[ id ]

	if type( self.StrText ) == "table" then
		self.TColor = self.StrText.Color or Color(255,255,255,255)

		self.StrText = self.StrText.Name
	end

	if self.StrText == "Theatre" then
		self.StrText = ("Theater")
		self.IsTheater = true
	end

	if self.StrText == "Hat Store" then
		self.StrText = ("Appearance Store")
	end

	if self.StrText == "Suites 10 - 16"  then
		self.StrText = ("Suites 10 - 15")
	elseif self.StrText == "Suites 17 - 24" then
		self.StrText = ("Suites 16 - 24")
	end

	if self.StrText == "Source Karts" && self.Entity:GetPos() == Vector(10784, 8600, 6912) then
		self.StrText = ""
	elseif self.StrText == "Source Karts" then
		self.StrText = "Source Karts"
	end

	if self.StrText == "Conquest" || self.StrText == "Gourmet Race" then
		self.StrText = ""
	end

	if self.StrText == "Ultimate Chimera Hunt" then
		self.StrText = "Chimera Hunt"
	end

	if self.StrText == "GMT: Adventure" then
		self.StrText = "Little Nostalgia"
	end

	local w,h = surface.GetTextSize( self.StrText )

	self.NegativeX = -w / 2
	self.PositiveY = -h

	self.TextWidth, self.TextHeight = w, h


	local min = Vector(0, self.NegativeX, 0)
	local max = Vector(0, -self.NegativeX, h )

	self:SetRenderBounds(min, max)

	if self.IsTheater then
		self.DrawExtra = self.DrawTheaterVideo
	end

end

function ENT:DrawTranslucent()

	// Aim the screen forward
	local ang = LocalPlayer():GetAimVector():Angle()
	local pos = self.Entity:GetPos() + ang:Up() * math.sin( CurTime() ) * 16 + ang:Right() * math.cos( CurTime() ) * 8

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	if (LocalPlayer():EyePos() - pos ):DotProduct( ang:Up() ) < 0 then
		ang:RotateAroundAxis( ang:Right(), 180 )
	end

	// Start the fun
	cam.Start3D2D( pos, ang, 0.5 )

		surface.SetFont( FONT )
		surface.SetTextColor( self.TColor.r, self.TColor.g, self.TColor.b, self.TColor.a )
		surface.SetTextPos( self.NegativeX, self.PositiveY )
		surface.DrawText( self.StrText )

		self:DrawExtra()

	cam.End3D2D()

end

function ENT:DrawExtra()

end

function ENT:DrawTheaterVideo()

	--[[if GTowerTheater.CurentlyPlaying == 0 then
		return
	end

	local Video = GTowerTheater.VoteData[ GTowerTheater.CurentlyPlaying ]

	if !Video || !Video.name then
		return
	end

	local Text = Video.name

	surface.SetFont( SMALLFONT )
	local w,h = surface.GetTextSize( Text )

	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( self.NegativeX + self.TextWidth / 2 - w / 2, self.PositiveY + self.TextHeight + 10 )
	surface.DrawText( Text )]]

end
