
function EFFECT:Init( data )

	local pos = data:GetOrigin()
	local norm = data:GetNormal()
	local life = 3
	local life_low = ( life * 0.8 ) * 10
	local life_high = ( life * 1.2 ) * 10
	local angle = Angle( math.random( -300, 300 ), math.random( -300, 300 ), math.random( -300, 300 ) )

	local color = data:GetStart()

	local pitch = angle.p
	local yaw = angle.y

	local maxParts = 500

	local emitter = ParticleEmitter( pos )
	for i = 1, maxParts do

		local pt = emitter:Add( "sprites/powerup_effects", pos + Vector( 0, 0, -500 ) + norm * math.random( 0, 32 ) + VectorRand() * math.random( 4, 6 ) )
		if i < ( maxParts / 2 ) then

			pt:SetVelocity( VectorRand():GetNormal() * 300 + Vector( 0, 0, 1000 ) )
			pt:SetGravity( Vector( math.random( -100, 100 ), math.random( -100, 100 ), -100 ) )

		else

			local rot = math.rad( ( 360 / 500 ) * i )
			local dir = Vector(
				math.cos( rot ),
				math.sin( rot ),
				0
			):Angle()

			dir:RotateAroundAxis( Vector( 0 , 1 , 0 ), pitch )
			dir:RotateAroundAxis( Vector( 0 , 0 , 1 ), yaw )
			dir = dir:Forward()

			pt:SetVelocity( dir * 175 + Vector( 0, 0, 1000 ) )
			pt:SetGravity( dir * 175 + Vector( 0, 0, -200 ) )

		end

		pt:SetDieTime( math.random( life_low, life_high ) * 0.1 )
		pt:SetAirResistance( 150 )
		pt:SetStartAlpha( 255 )
		pt:SetEndAlpha( 0 )
		pt:SetStartSize( 30 )
		pt:SetEndSize( 0 )
		pt:SetColor( color.r, color.g, color.b )
		--pt:VelocityDecay( false )
		pt:SetStartLength( 10 )
		pt:SetEndLength( 150 )

	end

	emitter:Finish()
	emitter = nil

end

function EFFECT:Think() end
function EFFECT:Render() end
