include("shared.lua")

ENT.SpriteMat = Material( "sprites/powerup_effects" )

function ENT:Initialize()

	self.Emitter = ParticleEmitter( self:GetPos() )
	self.RemoveEmitterTime = CurTime() + .5

end

function ENT:Draw()

	self:SetModelScale( .5 )
	self:DrawModel()

	render.SetMaterial( self.SpriteMat )
	render.DrawSprite( self:GetPos(), 15, 15, Color( 255, 128, 64 ) )

end

function ENT:Think()

	if !self.Emitter then return end

	if self.RemoveEmitterTime < CurTime() then

		self:RemoveEmitter()
		return

	end

	for i = 0, 2 do

		local particle = self.Emitter:Add( "effects/spark", self:GetPos() )
		if particle then

			particle:SetVelocity( VectorRand() * 10 + Vector( 0, 0, 50 ) )
			particle:SetDieTime( math.random( 5, 20 ) * 0.1 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 6 )
			particle:SetEndSize( 0 )
			particle:SetColor( math.random( 228, 255 ), math.random( 100, 128 ), math.random( 50, 64 ) )
			particle:SetStartLength( 10 )
			particle:SetEndLength( 0 )
			particle:SetRoll( math.random( 0, 360 ) )
			particle:SetGravity( Vector( 0, 0, -200 ) )
			particle:SetCollide( true )
			particle:SetBounce( 0.5 )

		end

	end

end

function ENT:RemoveEmitter()

	if self.Emitter then

		self.Emitter:Finish()
		self.Emitter = nil

	end

end

function ENT:OnRemove()

	self:RemoveEmitter()

end

// unreliable ffs
/*usermessage.Hook( "CornStuck", function( um )

	local ent = um:ReadEntity()

	if !IsValid( ent ) then return end

	if ent.RemoveEmitter then

		ent:RemoveEmitter()

	else

		if ent.Emitter then

		ent.Emitter:Finish()
		ent.Emitter = nil

		end

	end

end )*/
