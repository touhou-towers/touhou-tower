
-----------------------------------------------------
function EFFECT:Init( data )

	local offset = data:GetOrigin()
	local norm = data:GetNormal() or 0
	local emitter = ParticleEmitter( offset )

	//Sparks
	for i=0,1 do

		local particle = emitter:Add( "effects/energysplash", offset )

		if particle then

			local vec = norm * -0.1 + ( Angle( math.random( -180, 180 ), math.random( -180, 180 ), math.random( -180, 180 ) ):Forward() / 4 )
			particle:SetVelocity( vec * 1000 )
			particle:SetPos( offset + ( norm * 5 ) )
			particle:SetDieTime( 0.8 )
			particle:SetStartAlpha( 180 )
			particle:SetStartSize( 6 )
			particle:SetStartLength( 10 )
			particle:SetEndLength( 0 )
			particle:SetEndSize( 0 )
			particle:SetColor( 255, 150, 55 )
			particle:SetGravity( Vector( 0, 0, -700  ) )
			particle:SetBounce( 0.45 )
			particle:SetRoll( math.random( -5, 5 ) )
			particle:SetCollide( true )

		end

	end
	
	//Enery Debris
	local particle = emitter:Add( "sprites/flamelet" .. tostring( math.random( 1, 5 ) ), offset )
	
	if particle then

		particle:SetVelocity( ( VectorRand() * 1 ) * math.Rand( 25, 150 )  )
		particle:SetAngleVelocity( Angle( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) ) * 1200 )
		//particle:SetAngles( Angle( math.Rand( 0, 360 ), math.Rand( 0, 360 ), math.Rand( 0, 360 ) ) )
				
		particle:SetLifeTime( 0 )
		particle:SetDieTime( 1 )
				
		particle:SetStartSize( 8 )
		particle:SetEndSize( 0 )

		particle:SetColor( 255, 150, 55, 200 )

		particle:SetRoll( math.Rand(0, 360) )
		particle:SetRollDelta( math.Rand(-2, 2) )
				
		particle:SetAirResistance( 5 )

		particle:SetGravity( Vector( 0, 0, -800 ) )
		particle:SetBounce( 0.6 )
		particle:SetCollide( true )

	end

	//Flek
	local Dist = LocalPlayer():GetPos():Distance( offset )
	local FleckSize = math.Clamp( Dist * 0.01, 8, 64 )

	if ( math.random( 0, 1 ) == 1 ) then
		particle = emitter:Add( "effects/fleck_cement1", offset )
	else
		particle = emitter:Add( "effects/fleck_cement2", offset )
	end

	if particle then

		particle:SetVelocity( ( ( norm + VectorRand() * 0.5 ) * math.Rand( 150, 200 ) ) * -1 )
		//particle:SetLifeTime( i )
		particle:SetDieTime( 4 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 255 )
		particle:SetStartSize( FleckSize * math.Rand( 0.25, 0.5 ) )
		particle:SetEndSize( 0 )
		particle:SetLighting( true )
		particle:SetGravity( Vector( 0, 0, -800 ) )
		particle:SetAirResistance( 40 )
		particle:SetAngles( Angle( math.Rand( 0, 360 ), math.Rand( 0, 360 ), math.Rand( 0, 360 ) ) )
		//particle:SetAngleVelocity( Angle( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) ) * 800 )
		particle:SetCollide( true )
		particle:SetBounce( 0.2 )

	end

	emitter:Finish()

end

function EFFECT:Think() end
function EFFECT:Render() end