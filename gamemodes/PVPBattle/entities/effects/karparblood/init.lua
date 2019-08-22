EFFECT.KarparMat = Material("sprites/karpar")

function EFFECT:Init( data )
	
	self.entAttach = data:GetEntity()
	
	self.Pos = self.entAttach:LocalToWorld(self.entAttach:OBBCenter())
	self.Emitter = ParticleEmitter( self.Pos )

	self.StartTime = CurTime()

	self:Emit()

	self.Emitter:Finish()
end

function EFFECT:Emit()
	for i=0, 20 do
		local particle = self.Emitter:Add( "sprites/karpar", self.Pos )
		if (particle) then

			particle:SetLifeTime( 0 )
			particle:SetDieTime( 11 )
		
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 255 )
			particle:SetStartSize( 9 )
			particle:SetEndSize( 9 )

			particle:SetColor(255, 0, 0, 255)

			particle:SetCollide( false )
				
			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( math.Rand(-1, 1) )
				
			particle:SetGravity( Vector(math.random(-45, 45), math.random(-45,45), math.random(90, 100)) )
			
			particle:SetVelocity( Vector(math.random(-100, 100), math.random(-100,100), math.random(50, 80)) )

			particle:SetAngleVelocity( Angle( math.Rand( -2, 2 ), math.Rand( -2, 2 ), math.Rand( -2, 2 ) ) ) 
		end
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end