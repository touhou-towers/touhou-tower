
-----------------------------------------------------

include( "shared.lua" )

ENT.Font = "GTowerSkyMsgSmall"
ENT.Sides = 4

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:DrawCountdown()

	local ang = self.Entity:GetAngles()
	local pos = self:GetPos() - Vector( 0, 0, 60 )
	local AngleDivision = 360 / self.Sides
	local LocalPos = LocalPlayer():EyePos()
	local DrawList = {}

	ang.y = 0


	local timeLeft = self:TimeToNewYear()

	if ( timeLeft <= 0 ) then
		ang:RotateAroundAxis( ang:Up(), math.fmod( CurTime() * 5, 360 ) )
	end


	for i = 1, self.Sides do
		local DrawPos = pos + ang:Forward() * self.Distance

		local CurColor = nil

		if ( timeLeft <= 0 ) then
			CurColor = Color(
			100 + math.abs( math.sin( -CurTime() * 3.14 * i * 0.03 ) * 155 ),
			100 + math.abs( math.sin( CurTime()  * 2.71	* i * 0.03 ) * 155 ),
			100 + math.abs( math.sin( -CurTime() * 6 	* i * 0.03 ) * 155 ) )
		end

		table.insert( DrawList,
			{ DrawPos, Angle( ang.p, ang.y, ang.r ), LocalPos:Distance( DrawPos ), CurColor }
		)

		ang:RotateAroundAxis( ang:Up(), AngleDivision )
	end

	table.sort( DrawList, function( a, b )
		return a[3] > b[3]
	end )

	for _, v in ipairs( DrawList ) do
		self:DrawFace( v[1], v[2], v[4] )
	end

end

function ENT:DrawTranslucent()

	local timeLeft = self:TimeToNewYear()

	if ( timeLeft <= 0 ) then
		self:SetText( "   HAPPY NEW YEAR!!!   " )
	else
		local friendlyTime = {
			Second = timeLeft % 60,
			Minute = math.floor( timeLeft / 60 % 60 ),
			Hour = math.floor( timeLeft / 60 / 60 ),
		}

		self:SetText( "  " .. string.format( "%02i:%02i:%02i", friendlyTime.Hour, friendlyTime.Minute, friendlyTime.Second ) .. "  " )
	end

	self:DrawCountdown()
end


function ENT:SetText( text )

	surface.SetFont( self.Font )

	local w,h = surface.GetTextSize( text )

	self.NegativeX = -w / 2
	self.PositiveY = -h

	self.TextWidth, self.TextHeight = w, h
	self.Distance = w / 1.2
	self.StrText = text

end

function ENT:DrawFace( pos, ang, color )

	local Alpha = 100

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	if (LocalPlayer():EyePos() - pos ):DotProduct( ang:Up() ) < 0 then
		Alpha = 255
		ang:RotateAroundAxis( ang:Right(), 180 )
	end

	// Start the fun
	cam.Start3D2D( pos, ang, 1 )

		surface.SetFont( self.Font )

		if ( color == nil ) then
			surface.SetTextColor( 255, 255, 255, 255 )
		else
			surface.SetTextColor( color.r, color.g, color.b, 255 )
		end

		surface.SetTextPos( self.NegativeX, self.PositiveY )
		surface.DrawText( self.StrText )

	cam.End3D2D()


end

ENT.SpriteMat = Material( "sprites/powerup_effects" )

function ENT:Draw()

	self:DrawModel()
	self:SetModelScale( 8, 0 )

	local ang = self:GetAngles()
	ang.y = math.fmod( CurTime() * 20, 360 )
	ang.y = CurTime() * 20
	self:SetAngles( ang )

	local pos = self:GetPos() + Vector( 0, 0, 32 )
	local color = colorutil.Smooth( .03 )
	render.SetMaterial( self.SpriteMat )
	render.DrawSprite( pos, 512, 512, Color( color.r, color.g, color.b, 255 ) )

end

function ENT:Initialize()

	self:SetRenderBounds( Vector( -10000, -10000, -10000 ), Vector( 10000, 10000, 10000 ) )
	self:SharedInit()

	self.NextParticle = CurTime()
	self.Emitter = ParticleEmitter( self:GetPos() )

end

function ENT:Think()
	self:DrawParticles()

	local timeLeft = self:TimeToNewYear()

	if timeLeft == 307 and !self.MusicActive then
		self.MusicActive = true
		RunConsoleCommand("stopsound")
		timer.Simple(0.5,function()
			surface.PlaySound("gmodtower/lobby/countdown/finalcountdown.mp3")
		end)
	end

	if timeLeft == 5 and !self.CountingActive then
		self.CountingActive = true
		surface.PlaySound("vo/announcer_ends_5sec.mp3")
		timer.Simple(1,function()
			surface.PlaySound("vo/announcer_ends_4sec.mp3")
		end)
		timer.Simple(2,function()
			surface.PlaySound("vo/announcer_ends_3sec.mp3")
		end)
		timer.Simple(3,function()
			surface.PlaySound("vo/announcer_ends_2sec.mp3")
		end)
		timer.Simple(4,function()
			surface.PlaySound("vo/announcer_ends_1sec.mp3")
		end)
		timer.Simple(5,function()
			surface.PlaySound("gmodtower/music/overture.mp3")
		end)
	end

end

function ENT:DrawParticles()

	if not self.Emitter then
		self.Emitter = ParticleEmitter( self:GetPos() )
	end
	if !self.NextParticle then
		//return
	end
	if CurTime() > self.NextParticle then

		local pos = self:GetPos() + Vector( 0, 0, -256 ) + ( self:GetForward() * 0 )

		//local angle = Angle( SinBetween( -240, -190, CurTime() * 2 ), 0, 0 )
		//local angle = Angle( 0, SinBetween( -240, -120, CurTime() * 2 ), 0 )
		//local angle = Angle( 0, SinBetween( -360, 360, CurTime() * 2 ), 0 )
		local angle = Angle( 0, 0, SinBetween( -360, 360, CurTime() * 2 ) )
		local pitch = angle.p
		local yaw = angle.y

		for i=1, 10 do

			//local flare = Vector( 0, math.random( -10, 10 ), 0 )
			//local flare = Vector( 0, 0, math.random( -25, 25 ) )
			local size = 200
			local flare = Vector( CosBetween( -size, size, CurTime() * 2 ), SinBetween( -size, size, CurTime() * 2 ), size )
			local particle = self.Emitter:Add( "sprites/powerup_effects", pos + flare )

			if particle then

				//particle:SetVelocity( ( angle:Forward() * 50 ) )
				particle:SetVelocity( ( angle:Up() * 150 ) )
				//particle:SetDieTime( math.Rand( 2, 6 ) )
				particle:SetDieTime( math.Rand( .75, 2 ) )
				particle:SetStartAlpha( 150 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.random( 64, 80 ) )
				particle:SetEndSize( 32 )
				particle:SetGravity( ( angle:Forward() * 50 * -1 ) /*- ( flare / 3 )*/ )
				//particle:SetGravity( ( angle:Up() * 25 * -1 ) /* - ( flare / 3 ) */ )

				local color = colorutil.Smooth( .03 )
				particle:SetColor( color.r, color.g, color.b, 255 )

				particle:SetCollide( true )
				//particle:SetBounce( 1 )

			end
		end

		self.NextParticle = CurTime() + .001

	end

end

local function DoFireworks( um )
end

usermessage.Hook( "NewYears", DoFireworks )
