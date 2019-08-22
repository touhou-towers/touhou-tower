function EFFECT:Init( data )
	local pos = data:GetOrigin()
	local norm = data:GetEntity():GetUp()
	local num = 16
	
	local emitter = ParticleEmitter( pos )
		for i=1, num do
			local particle = emitter:Add( "sprites/Flames1/flame", pos )
			if (particle) then

				particle:SetVelocity( ( norm + VectorRand() * 1 ) * math.Rand( 50, 200 )  )
				particle:SetAngleVelocity( Angle( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) ) * 1600 )
				particle:SetAngles( Angle( math.Rand( 0, 360 ), math.Rand( 0, 360 ), math.Rand( 0, 360 ) ) )
				
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 5 )
				
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				
				particle:SetStartSize( 32 )
				particle:SetEndSize( 0 )

				particle:SetColor( 70, 255, 70 )

				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-2, 2) )
				
				particle:SetAirResistance( 5 )
				particle:SetLighting( true )

				particle:SetGravity( Vector( 0, 0, -800 ) )
				particle:SetBounce( 0.2 )
				particle:SetCollide( true )
				
			end
		end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end