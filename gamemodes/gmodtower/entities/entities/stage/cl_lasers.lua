

-----------------------------------------------------

local lasermat 	= 		Material("effects/laser1.vmt")

function ENT:SetLaserNoteRange( min, max )
	self.laserRange = { min, max }
end

function ENT:RandomLaserThing()
	local note = math.random( self.laserRange[1], self.laserRange[2] )
	local pitch = math.random( -300, 300 )
	self:LaserNote(note)
	self:LaserPitchBend(pitch)
end

function ENT:LaserNote( note )
	self.laserOffTime = 0
	self.laserOnTime = CurTime()
	self.laserNote = ( note - self.laserRange[1] ) / ( self.laserRange[2] - self.laserRange[1] )
	self.laserPitch = self.laserPitch or 0
	self.laserTween = self.laserTween or 0
	self.activeNotes = self.activeNotes or {}
	self.activeNotes[note] = true
end

function ENT:LaserOff( note )
	self.laserOffTime = CurTime()

	self.activeNotes[note] = nil
end

function ENT:LaserPitchBend( bend )
	self.laserPitch = bend
end

function ENT:DeriveUpVector( pitch, yaw )
	local ang = Vector(0,0,1):Angle()
	ang:RotateAroundAxis( Vector(1,0,0), -pitch )
	ang:RotateAroundAxis( Vector(0,0,1), yaw )

	return ang:Forward()
end

function ENT:DrawLaser( att, num, bright )
	local forward = Vector(0,0,1)
	
	local t = CurTime()
	local st = 1.2 - ( self.laserNote - .5 ) * 1.5 --math.cos(t)

	st = st - self.laserPitch / 2000


	self.laserTween = self.laserTween + ( st - self.laserTween ) * .04


	local spreadAmount = math.fmod(self.laserNote * 30, 4) * 4

	for i=1, 3 do
		local spreadH = math.cos(i*4 + CurTime() * 3) * spreadAmount
		local spreadV = math.sin(i*4 + CurTime() * 3) * spreadAmount
		local forward = self:DeriveUpVector( 
			-50 * self.laserTween + spreadH, 
			(num-2.5) + spreadV )

		local start_pos = att.pos
		local end_pos = start_pos + forward * ( 700 - i * 60 )

		local hue = ( st * 180 ) + i * 40
		local r,g,b = colorutil.HSV( hue, 1, 255 )
		local color = Color( r * bright, g * bright, b * bright, 255 * bright )

		self:DrawBasicSprite( self.Mat.Flare2, start_pos, -forward:Angle(), 150, color )

		render.SetMaterial( lasermat );
		render.StartBeam( 2 );
		render.AddBeam(
			start_pos,
			30,
			CurTime(),
			color		// Color
		);
		render.AddBeam(
			end_pos,
			30,
			CurTime() + 1,
			Color( 0, 0, 0, 0 )
		); 	
		render.EndBeam();
	end
end

function ENT:DrawLasers()

	if !self.laserOnTime then return end
	if not next(self.activeNotes) then return end

	--if self.laserOffTime and ( self.laserOffTime - self.laserOnTime ) > .05 then return end

	local t = CurTime()
	local dt = 1 - math.Clamp( (t - self.laserOnTime) / 5, 0, .8 ) * 1.2

	if dt < .1 then dt = 0 end

	for id, att in pairs( self.Att.Lasers ) do
		self:DrawLaser( att, id, dt )
		--self:DrawBasicSprite( self.Mat.Flare2, att.pos, att.ang, 150, colorutil.Smooth( .25 ) )
	end
end