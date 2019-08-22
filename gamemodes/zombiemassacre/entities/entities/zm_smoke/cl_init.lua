include( "shared.lua" )
function ENT:Initialize()
	self.Color = Color( 255, 255, 255, 255 )
	self.Emitter = ParticleEmitter( self:GetPos() )
	self.DieTime = CurTime() + 5
	self.Gravity = 50
	
end
function ENT:OnRemove()
	if IsValid( self.Emitter ) then
		self.Emitter:Finish()
		self.Emitter = nil
	end
end
function ENT:Think()
	if not self.Emitter then
		self.Emitter = ParticleEmitter( self:GetPos() )
	end
	// Force on ground
	local tr = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:GetPos() + Vector( 0, 0, -1000 ),
		filter = self,
	} )
	if tr.HitWorld then
		self:SetPos( tr.HitPos )
	end
	for i=0, 3 do
		if math.random( 3 ) > 1 then
			local particle = self.Emitter:Add( "particles/smokey", self:GetPos() )
			if particle then
				particle:SetVelocity( VectorRand() * 40 )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand(1.0,1.5) )
				particle:SetStartAlpha( math.Rand(150,200) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.random(5,10) )
				particle:SetEndSize( math.random(15,35) )
				local dark = math.Rand(50,100)
				particle:SetColor( dark, dark, dark )
				particle:SetAirResistance( 50 )
				if self.Gravity then
					self.Gravity = Lerp( self.DieTime - CurTime() * .1, gravity, 300 )
				end
				particle:SetGravity( Vector( 0, 0, self.Gravity ) )
				particle:SetCollide( false )
			end
		end
	end
end