
EFFECT.Mat = Material("sprites/pickup_light")

function EFFECT:Init( data )
	local origin = data:GetOrigin()
	local count = math.Clamp( ( data:GetRadius() * 2 ), 10, 500 )

	local emitter = ParticleEmitter( origin )

		for i = 0, count do
			local pos = origin + ( VectorRand() * ( data:GetRadius() * 0.75 ) )
			local vel = VectorRand() * 50

			local particle = emitter:Add( "sprites/pickup_light", pos )
			if (particle) then
				particle:SetVelocity( vel )
				particle:SetDieTime( math.Rand( 0.25, 0.75 ) )
				particle:SetStartAlpha( 250 )
				particle:SetEndAlpha( 210 )
				particle:SetStartSize( 12 )
				particle:SetEndSize( 0 )
				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetRollDelta( math.Rand( -5.5, 5.5 ) )
				particle:SetColor( 255, 255, 255 )
			end
		end
	emitter:Finish()
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()	
end