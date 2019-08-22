EFFECT.LightMat = Material("sprites/pickup_light")

function EFFECT:Init( data )

	local origin = data:GetEntity():GetPos()
	
	if !IsValid( origin ) then
		return
	end
	
	local count = math.Clamp( ( data:GetRadius() * 2 ), 10, 500 )

	local emitter = ParticleEmitter( origin )

		for i = 0, count do

			local pos = origin + ( VectorRand() * ( data:GetRadius() * 0.75 ) )
			local vel = VectorRand() * 10
			local particle = emitter:Add( "sprites/pickup_light", pos )
				particle:SetVelocity( vel )
				particle:SetDieTime( math.Rand( 1, 3 ) )
				particle:SetStartAlpha( 250 )
				particle:SetEndAlpha( 210 )
				particle:SetStartSize( 12 )
				particle:SetEndSize( 0 )
				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetRollDelta( math.Rand( -5.5, 5.5 ) )
				particle:SetColor( 255, 240, 70 )

		end

	emitter:Finish()

end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()	
end