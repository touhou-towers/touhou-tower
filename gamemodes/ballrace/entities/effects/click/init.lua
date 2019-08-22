EFFECT.Mat = Material("effects/spark")

function EFFECT:Init( data )
	
	local vOffset = data:GetOrigin()
	local vNorm = data:GetNormal()
	
	local NumParticles = 16
	
	local emitter = ParticleEmitter( vOffset )
	
		for i=1, NumParticles do
		
			local particle = emitter:Add( "effects/spark", vOffset )
			if (particle) then
				
				local angle = vNorm:Angle()
				particle:SetVelocity( angle:Forward() * math.Rand(100, 200) + angle:Right() * math.Rand(-200, 200) + angle:Up() * math.Rand(-200, 200) )
				
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 1 )
				
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				
				particle:SetStartSize( 3 )
				particle:SetEndSize( 0 )
				
				particle:SetRoll( math.Rand(0, 360) )
				
				particle:SetAirResistance( 400 )
				
				particle:SetGravity( vNorm * 100 )
			
			end
			
		end
		
	emitter:Finish()
	
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end
