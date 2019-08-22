
-----------------------------------------------------
function EFFECT:Init( data )
	
	local pos = data:GetOrigin()
	local emitter = ParticleEmitter( pos )

	// Splashes
	for i=1, 10 do

		local particle = emitter:Add( "effects/splash4", pos )
		if particle then
			particle:SetVelocity( ( VectorRand():GetNormal() * 40 ) + Vector( 0, 0, 160 ) )
			particle:SetLifeTime( 0 )
			particle:SetDieTime( math.Rand( 5.2, 8.0 ) / 1.8 )
			particle:SetStartAlpha( math.Rand( 80, 155 ) )
			particle:SetEndAlpha( 0 )

			particle:SetStartSize( 10 )
			particle:SetEndSize( 50 )
			particle:SetRoll( math.Rand( 0, 360 ) )
			particle:SetRollDelta( math.Rand( -10, 10 ) )
			particle:SetColor(255,255,255, 150)

			local function collided( particle, HitPos, Normal )

				particle:SetAngleVelocity( Angle( 0, 0, 0 ) )
				particle:SetRollDelta( 0 )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 0.7 )
				particle:SetVelocity( Vector( 0, 0, 0 ) )
				particle:SetGravity( Vector( 0, 0, 0 ) )

			end

			particle:SetCollideCallback( collided )
			particle:SetAirResistance( math.Rand( 6, 18 ) )
			particle:SetGravity( Vector( 0, 0, math.random(-400,-300) ) )
			particle:SetCollide( true )
			particle:SetBounce( 0 )

		end

	end
		
	emitter:Finish()
	
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end