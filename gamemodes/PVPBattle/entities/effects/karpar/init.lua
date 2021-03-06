EFFECT.KarparMat = Material("sprites/karpar")

function EFFECT:Init( data )
	
	self.vOrigin = data:GetOrigin()
		self.Emitter = ParticleEmitter( self.vOrigin )

	self.BoxCoords = {-256,256,-256,256}

	self.NumPerSecond = 4
	self.EmitWait = 1/self.NumPerSecond

	self.EmitTime = 0
	self:Emit()
end

function EFFECT:Emit()
	if CurTime() < self.EmitTime + self.EmitWait then return end
	self.EmitTime = CurTime()

	local coord = Vector(math.random(self.BoxCoords[1], self.BoxCoords[2]), math.random(self.BoxCoords[3], self.BoxCoords[4]), 512)
	local particle = self.Emitter:Add( "sprites/karpar", self.vOrigin + coord )
	if (particle) then

		particle:SetLifeTime( 0 )
		particle:SetDieTime( 11 )
		
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 255 )
		particle:SetStartSize( 9 )
		particle:SetEndSize( 9 )

		particle:SetCollide( true )
				
		particle:SetRoll( math.Rand(0, 360) )
		particle:SetRollDelta( math.Rand(-1, 1) )
			
		particle:SetGravity( Vector(math.random(0, 5), 0, -math.random(15,25)) )
			
		particle:SetAngleVelocity( Angle( math.Rand( -2, 2 ), math.Rand( -2, 2 ), math.Rand( -2, 2 ) ) ) 
	end
end

function EFFECT:Think()
	self:Emit()
	return true
end

function EFFECT:Render()
end 