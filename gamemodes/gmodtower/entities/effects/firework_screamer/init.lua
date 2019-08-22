
function EFFECT:Init( data )

	local low = data:GetOrigin() - Vector( 15, 15, 50 )
	local high = data:GetOrigin() + Vector( 15, 15, 50 )
	local color = data:GetStart()

	local emitter = ParticleEmitter( low )

	for i = 0, 50 do

		local pos = Vector( math.Rand( low.x, high.x ), math.Rand( low.y, high.y ), math.Rand( low.z, high.z ) )

		local particle = emitter:Add( "effects/yellowflare", pos )
		if particle then

			particle:SetVelocity( VectorRand() * 15 )
			particle:SetColor( color.r, color.g, color.b )
			particle:SetDieTime( math.Rand( 5, 8 ) )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.Rand( 10, 15 ) )
			particle:SetEndSize( 0 )
			particle:SetRoll( math.Rand( -360, 360 ) )
			particle:SetRollDelta( math.Rand( -50, 50 ) )

			particle:SetAirResistance( math.random( 50, 100 ) )
			particle:SetGravity( Vector( 0, 0, math.random( -100, -50 ) ) )
			particle:SetCollide( true )
			particle:SetBounce( 0.5 )

		end

	end

	emitter:Finish()

end

function EFFECT:Think( ) return false end
function EFFECT:Render() end