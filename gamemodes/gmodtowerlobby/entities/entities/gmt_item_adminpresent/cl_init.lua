
-----------------------------------------------------
include("shared.lua")

ENT.Color = nil
ENT.SpriteMat = Material( "sprites/powerup_effects" )

function ENT:Initialize()

	timer.Simple( 1, function()

		if IsValid( self ) then
			self.BaseClass:Initialize()
			self.OriginPos = self:GetPos()
			self.NextParticle = CurTime()
			self.TimeOffset = math.Rand( 0, 1.14 )

			self.Emitter = ParticleEmitter( self:GetPos() )
		end

	end )

end

function ENT:Draw()

	if !self.OriginPos || !self.TimeOffset then return end

	self:DrawModel()

	render.SetMaterial( self.SpriteMat )
	render.DrawSprite( self:GetPos(), 100+ math.cos(CurTime())*2, 100 + math.sin(CurTime())*2, self.Color )

end

function ENT:Think()

	local rot = self:GetAngles()
	rot.y = rot.y + 90 * FrameTime()

	self.Color = colorutil.Rainbow(200)

	self:SetAngles(rot)
	self:SetRenderAngles(rot)

	if !self.OriginPos || !self.TimeOffset then return end

	local SinTime = math.sin( CurTime() + self.TimeOffset )
	self:SetRenderOrigin( self.OriginPos + Vector(0,0, 5 +  SinTime * 4 ) )

	if CurTime() > self.NextParticle then
		local emitter = self.Emitter

		local pos = self:GetPos() + ( VectorRand() * ( self:BoundingRadius() * 0.75 ) )
		local vel = VectorRand() * 3

		vel.z = vel.z * ( vel.z > 0 && -3 or 3 )

		local particle = emitter:Add( "sprites/powerup_effects", pos )

		if particle then
			particle:SetVelocity( vel * 1.5 )
			particle:SetDieTime( math.Rand( 1, 3 ) )
			particle:SetStartAlpha( 100 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 25 )
			particle:SetEndSize( 0 )
			particle:SetRoll( math.Rand( 0, 360 ) )
			particle:SetRollDelta( math.Rand( -5.5, 5.5 ) )


			particle:SetColor( self.Color.r, self.Color.g, self.Color.b )
		end

		self.NextParticle = CurTime() + 0.025
	end

end
