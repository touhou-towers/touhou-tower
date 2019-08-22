function EFFECT:Init( data )
	local mat = "effects/yellowflare"
	local pos = data:GetOrigin()

	local emitter = ParticleEmitter( pos )
	local particle = emitter:Add( mat, pos )
	if particle then
		particle:SetVelocity( Vector( 0, 0, 0 ) )
		particle:SetDieTime( 1.5 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 150 )
		particle:SetEndSize( 0 )
		particle:SetRoll( math.random( -360, 360 ) )
		particle:SetRollDelta( math.random( -200, 200 ) )
		particle:SetColor( 200, 200, 255 )
	end	
	emitter:Finish()
	
	local force = math.random( 200, 250 )
	local emitter2 = ParticleEmitter( pos )
	for i=1, 55 do
		local particle = emitter:Add( mat, pos )
		if particle then
			particle:SetVelocity( Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( 0, 1 ) ) * force )

			particle:SetLifeTime( 0 )
			particle:SetDieTime( math.Rand( 0.5, 1.5 ) )

			particle:SetColor( 255, 230, 50 )

			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )

			particle:SetStartSize( 25 )
			particle:SetEndSize( 6 )

			particle:SetCollide( true )
			particle:SetBounce( 2 )

			particle:SetAirResistance( 50 )
			particle:SetGravity( Vector( 0, 0, -180 ) )
		end
	end
	emitter2:Finish()
end

function EFFECT:Think( ) return false end
function EFFECT:Render() end