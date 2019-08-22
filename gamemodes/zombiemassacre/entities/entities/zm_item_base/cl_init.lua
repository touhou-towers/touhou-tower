include( "shared.lua" )
ENT.Color = Color( 255, 255, 255, 200 )
ENT.SpriteMat = Material( "sprites/powerup_effects" )
ENT.ScaleFraction = 1
function ENT:Initialize()
	self.NextParticle = CurTime()
	self.TimeOffset = math.Rand( 0, 3.14 )
	self.Emitter = ParticleEmitter( self:GetPos() )
	self.Scale = self.ScaleFraction * 1
end
function ENT:Draw()

	self:DrawModel()
	self.Scale = math.Approach( self.Scale, self.ScaleTo, FrameTime() * 10 )
	self:SetModelScale( self.Scale, 0 )
	render.SetMaterial( self.SpriteMat )
	render.DrawSprite( self:GetPos(), 80, 80, Color( math.random(0, 255), math.random(0, 255), math.random(0, 255) ) )
	/*local pos = self:GetPos() + Vector( 0, 0, 30 )
	cam.Start3D2D( pos, Angle( 0, 270, 90 ), 1 )
		draw.DrawText( self.Text, "ZomSmall", -40, 0, self.Color )
	cam.End3D2D()*/
end
function ENT:OnRemove()
	if IsValid( self.Emitter ) then
		self.Emitter:Finish()
		self.Emitter = nil
	end
	
end
function ENT:Think()
	self.ScaleTo = self.ScaleFraction * 1.5
	if self:IsInRadius( LocalPlayer(), 128 ) then
		self.ScaleTo = self.ScaleFraction * 2
	end
	local rot = self:GetAngles()
	rot.y = rot.y + 90 * FrameTime()
	self:SetAngles(rot)	
	self:SetRenderAngles(rot)
	if not self.Emitter then return end
	if CurTime() > self.NextParticle then
		local pos = self:GetPos() + ( VectorRand() * ( self:BoundingRadius() * 0.75 ) )
		local vel = VectorRand() * 3
		
		vel.z = vel.z * ( vel.z > 0 && -3 or 3 )
		local particle = self.Emitter:Add( "sprites/orangeflare1", pos )
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
		particle = self.Emitter:Add( "sprites/light_glow02_add", self:GetPos() + ( Vector( math.random( -4, 4 ), math.random( -4, 4 ), 0 ) * 3 ) - Vector( 0, 0, 10) )
		if particle then
				particle:SetColor( self.Color.r, self.Color.g, self.Color.b, 255)
				particle:SetVelocity( Vector( math.random( -4, 4 ), math.random( -4, 4 ), 0 ):GetNormal() * 20 )
				particle:SetGravity( Vector( 0, 0, -75 ) )
				particle:SetDieTime( 1.25 )
				particle:SetLifeTime( 0 )
				particle:SetStartSize( 25 )
				particle:SetEndSize( 0 )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
		end
		self.NextParticle = CurTime() + 0.15
	end
end
function ENT:IsInRadius( ent, radius )
	return self:GetPos():Distance( ent:GetPos() ) < radius
end