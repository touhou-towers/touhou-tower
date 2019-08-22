

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

				particle:SetDieTime( 3 )
				
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				
				particle:SetStartSize( 12 )
				particle:SetEndSize( 5 )

				particle:SetColor( 255, 255, math.Rand(0, 50) )

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