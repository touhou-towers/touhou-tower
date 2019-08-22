
-----------------------------------------------------
function EFFECT:Init( data )
	local Pos = data:GetOrigin()
	local Norm = data:GetNormal()
	local Scale = data:GetScale()

	local SurfaceColor = render.GetSurfaceColor( Pos+Norm, Pos-Norm*100 ) * 255

	SurfaceColor.r = math.Clamp( SurfaceColor.r+40, 0, 255 )
	SurfaceColor.g = math.Clamp( SurfaceColor.g+40, 0, 255 )
	SurfaceColor.b = math.Clamp( SurfaceColor.b+40, 0, 255 )

	local Dist = LocalPlayer():GetPos():Distance( Pos )
	local FleckSize = math.Clamp( Dist * 0.01, 8, 64 )

	local emitter = ParticleEmitter( Pos, true )
		for i =0, 2 * Scale do
			local particle

			if ( math.random( 0, 1 ) == 1 ) then
				particle = emitter:Add( "effects/fleck_cement1", Pos )
			else
				particle = emitter:Add( "effects/fleck_cement2", Pos )
			end

			particle:SetVelocity( (Norm + VectorRand() * 1) * math.Rand( 50, 200 ) )
			particle:SetDieTime( 1.5 )
			particle:SetStartAlpha( 150 )
			particle:SetEndAlpha( 150 )
			local Size = FleckSize * math.Rand( 0.8, 1.4 )
			particle:SetStartSize( Size )
			particle:SetEndSize( 0 )
			particle:SetLighting( true )
			particle:SetGravity( Vector( 0, 0, -800 ) )
			particle:SetAirResistance( 5 )
			particle:SetAngles( Angle( math.Rand( 0, 360 ), math.Rand( 0, 360 ), math.Rand( 0, 360 ) ) )
			particle:SetAngleVelocity( Angle( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) ) * 1600 )
			particle:SetCollide( true )
			particle:SetBounce( 0.2 )

			if ( math.fmod( i, 2 ) == 0 ) then
				particle:SetColor( 0, 0, 0 )
			end
		end
	emitter:Finish()
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()	
end