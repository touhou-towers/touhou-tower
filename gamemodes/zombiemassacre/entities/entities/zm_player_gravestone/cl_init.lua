include("shared.lua")

ENT.Color = Color( 128, 0, 128, 255 )
ENT.SpriteMat = Material( "sprites/powerup_effects" )

function ENT:Initialize()

	self.Pos = self:GetPos()

	//Offset the spawn down.
	self.Offset = 120
	self:SetPos( self.Pos - Vector( 0, 0, self.Offset ) )

	//Store this position and calculate how much to move it up.
	self.MoveUnits = self.Offset * .25
	self.EndPos = self.Pos.z + self.MoveUnits

	self.SmokeOffset = Vector( 0, 0, -30 )  //Set smoke offset.

	self.NextParticle = CurTime()
	self.Emitter = ParticleEmitter( self.Pos )

end

function ENT:OnRemove()

	if self.Emitter then
	
		self.Emitter:Finish()
		self.Emitter = nil

	end

end

function ENT:Draw()

	self:DrawModel()

	render.SetMaterial( self.SpriteMat )
	render.DrawSprite( self.Pos, 50, 50, self.Color ) 

end

function ENT:Think()

	//Move it up until the end.
	if self.Pos.z < self.EndPos then

		self.Pos.z = self.Pos.z + self.MoveUnits * FrameTime()

	else

		self.SmokeOffset = Vector( 0, 0, 25 )

	end

	self:SetPos( self.Pos )

	self:ParticleThink()
	
end

function ENT:ParticleThink()

	if !self.Emitter then
		self.Emitter = ParticleEmitter( self.Pos )
	end

	//Sprites
	if CurTime() > self.NextParticle then

		local pos = self.Pos + ( VectorRand() * ( self:BoundingRadius() * 0.75 ) )
		local vel = VectorRand() * 3
		vel.z = vel.z * ( vel.z > 0 && -3 or 3 )

		local particle = self.Emitter:Add( "sprites/powerup_effects", pos )

		if particle then

			particle:SetVelocity( vel )
			particle:SetDieTime( math.Rand( 1, 3 ) )
			particle:SetStartAlpha( 100 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 60 )
			particle:SetEndSize( 0 )
			particle:SetRoll( math.Rand( 0, 360 ) )
			particle:SetRollDelta( math.Rand( -5.5, 5.5 ) )
			particle:SetColor( self.Color.r, self.Color.g, self.Color.b )

		end

		self.NextParticle = CurTime() + 0.15

	end

	//Smoke
	local Gravity = Vector( 0, 0, -10 )
	local Velocity = self:GetVelocity()

	self.LastParticlePos = self.LastParticlePos or self.Pos or self:GetPos()

	local vDist = self.Pos - self.SmokeOffset - self.LastParticlePos
	local Length = vDist:Length()
	local vNorm = vDist:GetNormalized()

	for i=0, Length, 8 do

		self.LastParticlePos = self.LastParticlePos + vNorm * 8
		self.ParticlesSpawned = self.ParticlesSpawned or 1
		self.ParticlesSpawned = self.ParticlesSpawned + 1

		if math.random(3) > 1 then

			local particle = self.Emitter:Add( "particles/smokey", self.LastParticlePos )
			
			if particle then

				particle:SetVelocity( VectorRand() * 40 ) 
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 1.0, 1.5 ) )
				particle:SetStartAlpha( math.Rand( 5, 80 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.random( 5, 10) )
				particle:SetEndSize( math.random( 8, 30 ) )
				local dark = math.Rand( 100, 200 )
				particle:SetColor( dark, dark, dark )
				particle:SetAirResistance( 50 )
				particle:SetGravity( Vector( 0, 0, math.random( -50, 50 ) ) )
				particle:SetCollide( true )
				particle:SetBounce( 0.2 )

			end

		end

	end

end