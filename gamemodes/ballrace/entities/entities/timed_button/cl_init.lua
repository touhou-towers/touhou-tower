include('shared.lua')

ENT.Sprite = Material("effects/blueflare1")

function ENT:Initialize()
	self.BaseClass:Initialize()

	self.Pos = self:GetPos()

	self.NextParticle = CurTime()
	self.Emitter = ParticleEmitter( self.Pos )
end

function ENT:Draw()
	self:DrawModel()
	self:SetColor(Color(0,255,0))
end

function ENT:Think()
	if !self.isPressed then
		if CurTime() > self.NextParticle then
			local emitter = self.Emitter

			local pos = self.Pos + ( VectorRand() * ( self:BoundingRadius() * 0.75 ) )
			local vel = VectorRand() * 3

			vel.z = vel.z * ( vel.z > 0 && -3 or 3 )

			local particle = emitter:Add( "sprites/powerup_effects", pos )

			if particle then
				particle:SetVelocity( vel )
				particle:SetDieTime( math.Rand( 1, 3 ) )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 80 )
				particle:SetEndSize( 10 )
				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetRollDelta( math.Rand( -5.5, 5.5 ) )
				particle:SetColor( math.random( 15, 25 ), math.random( 100, 255 ), math.random( 15, 25 ) )
			end

			self.NextParticle = CurTime() + 0.15
		end
	end
end

usermessage.Hook("ButtonPress", function( um )
	local ent = um:ReadEntity()
	if !IsValid( ent ) then return end
	ent.isPressed = true
end)
