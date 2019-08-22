
function EFFECT:Init( data )
	local vOffset = data:GetOrigin()
	local vNorm = data:GetNormal()
	
	self.Red = 0
	self.Green = 0
	self.Blue = 0

	local dice = math.random(1,3)

	if dice == 1 then
		self.Red = 255
	elseif dice == 2 then
		self.Blue = 255
	else
		self.Red = 255
		self.Green = 255
		self.Blue = 255
	end	

	local NumParticles = 8
	
	local emitter = ParticleEmitter( vOffset )
		for i=1, NumParticles do
			local particle = emitter:Add( "sprites/star", vOffset )
			if (particle) then
				local angle = vNorm:Angle()
				particle:SetVelocity( angle:Forward() * math.Rand(0, 200) + angle:Right() * math.Rand(-200, 200) + angle:Up() * math.Rand(-200, 200) )

				particle:SetDieTime( 3 )
				
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				
				particle:SetStartSize( 12 )
				particle:SetEndSize( 5 )

				particle:SetColor( self.Red,self.Green,self.Blue )

				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-2, 2) )
				
				particle:SetAirResistance( 100 )

				particle:SetGravity( vNorm * 50 )
			
			end
		end
	emitter:Finish()
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end