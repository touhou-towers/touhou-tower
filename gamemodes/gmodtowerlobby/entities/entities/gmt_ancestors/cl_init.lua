include("shared.lua")

ENT.Color = nil
ENT.SpriteMat = Material( "sprites/powerup_effects" )

function ENT:Initialize()

	self.NextParticle = CurTime() + 0.15

	self.csModel = ClientsideModel("models/gmod_tower/headheart.mdl")
	self:DrawShadow(false)

		if IsValid( self ) then
			self.BaseClass:Initialize()
			self.OriginPos = self:GetPos()
			self.NextParticle = CurTime()
			self.TimeOffset = math.Rand( 0, 3.14 )

			self.Emitter = ParticleEmitter( self:GetPos() )
		end

end

function ENT:Draw()
	local bananaAngle = (CurTime() * 75) % 360
	local bananaHeight = math.sin(CurTime() * 1) * 1.5

	self.csModel:SetPos(self:GetPos() + Vector(0,0, bananaHeight + 10))
	self.csModel:SetAngles(Angle(0,bananaAngle,0))

	render.SetMaterial( self.SpriteMat )
	render.DrawSprite( self:GetPos(), 50, 50, self.Color )

end

function ENT:OnRemove()
	self.csModel:Remove()
end
function ENT:Think()

	self.Color = colorutil.Rainbow(200)

	if CurTime() > self.NextParticle then
		local emitter = self.Emitter

		local pos = self:GetPos() + ( VectorRand() * ( self:BoundingRadius() * 0.75 ) )
		local vel = VectorRand() * 3

		vel.z = vel.z * ( vel.z > 0 && -3 or 3 )

		local particle = emitter:Add( "sprites/powerup_effects", pos )

		if particle then
			particle:SetVelocity( vel )
			particle:SetDieTime( math.Rand( 1, 3 ) )
			particle:SetStartAlpha( 100 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 18 )
			particle:SetEndSize( 0 )
			particle:SetRoll( math.Rand( 0, 360 ) )
			particle:SetRollDelta( math.Rand( -5.5, 5.5 ) )


			particle:SetColor( self.Color.r, self.Color.g, self.Color.b )
		end

		self.NextParticle = CurTime() + 0.15
	end
	
	if !IsValid(self.csModel) then
		self.csModel = ClientsideModel("models/gmod_tower/headheart.mdl")
	end
	
end
