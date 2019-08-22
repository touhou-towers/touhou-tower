
-----------------------------------------------------
function EFFECT:Init( data )
	local vOffset = data:GetOrigin()
	local vNorm = data:GetNormal()
	
	local NumParticles = 8
	
	local emitter = ParticleEmitter( vOffset )
		for i=1, NumParticles do
			local particle = emitter:Add( "sprites/star", vOffset )
			if (particle) then
				local angle = vNorm:Angle()
				particle:SetVelocity( angle:Forward() * math.Rand(0, 200) + angle:Right() * math.Rand(-200, 200) + angle:Up() * math.Rand(-200, 200) )
				
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 1 )
				
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				
				particle:SetStartSize( 5 )
				particle:SetEndSize( 1 )

				particle:SetColor( 255, 255, math.Rand(0, 50) )

				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-2, 2) )
				
				particle:SetAirResistance( 100 )

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