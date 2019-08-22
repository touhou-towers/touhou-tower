include('shared.lua')

ENT.Sprite = Material("effects/blueflare1")

function ENT:Initialize()
	self.BaseClass:Initialize()

	self.Pos = self:GetPos()
	self.MoveUnits = 5
	self.EndPos = self.Pos.z - self.MoveUnits

	self.NextParticle = CurTime()
	self.Emitter = ParticleEmitter( self.Pos )
end

function ENT:Draw()
	self:DrawModel()

	if !self.isPressed then return end

	render.SetMaterial( self.Sprite )
	render.DrawSprite( self:GetPos() + Vector( 0, 0, 10 ), 150, 150, Color( 255, 0, 0, 255 ) ) 
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
				particle:SetColor( math.random( 50, 255 ), math.random( 50, 255 ), math.random( 50, 255 ) )
			end

			self.NextParticle = CurTime() + 0.15
		end
	else
		if self.EndPos < self.Pos.z then
			self.Pos.z = self.Pos.z - self.MoveUnits * FrameTime()
			self:SetPos( self.Pos )
		end
	end
end

usermessage.Hook("ButtonPress", function( um )
	local ent = um:ReadEntity()
	if !IsValid( ent ) then return end
	ent.isPressed = true
end)