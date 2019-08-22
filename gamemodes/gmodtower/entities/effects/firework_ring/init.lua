
function EFFECT:Init( data )

	local pos = data:GetOrigin()
	local norm = data:GetNormal()
	local life = 2
	local life_low = ( life * 0.8 ) * 10
	local life_high = ( life * 1.2 ) * 10
	local angle = Angle( math.random( 0, 30 ), math.random( 0, 30 ), math.random( 0, 30 ) )
	local color = data:GetStart()

	local emitter = ParticleEmitter( pos )

	local pitch = angle.p
	local yaw = angle.y

	for i = 1, 300 do

		local rot = math.rad( ( 360 / 300 ) * i )

		local dir = Vector(
			math.cos( rot ),
			math.sin( rot ),
			0
		):Angle()

		dir:RotateAroundAxis( Vector( 0 , 1 , 0 ), pitch )
		dir:RotateAroundAxis( Vector( 0 , 0 , 1 ), yaw )

		dir = dir:Forward()

		local particle = emitter:Add( 'effects/spark' , pos )
		particle:SetVelocity( ( dir * 400 ) )
		particle:SetDieTime( math.random( life_low, life_high ) * 0.1 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 30 )
		particle:SetEndSize( 0 )
		particle:SetColor( color.r, color.g, color.b )
		particle:SetStartLength( 16 )
		particle:SetEndLength( 40 )
		particle:SetAirResistance( 150 )
		--particle:VelocityDecay( false )
		particle:SetGravity( Vector( 0 , 0 , -math.random( 80 , 200 ) ) )

	end

	for i = 1, 500 do

		local pt = emitter:Add( "sprites/powerup_effects", pos + norm * math.random( 0, 32 ) + VectorRand() * math.random( 4, 6 ) )
		pt:SetVelocity( VectorRand():GetNormal() * 700 )
		pt:SetDieTime( math.random( life_low, life_high ) * 0.1 )
		pt:SetAirResistance( 400 )
		pt:SetStartAlpha( 255 )
		pt:SetEndAlpha( 0 )
		pt:SetStartSize( 10 )
		pt:SetEndSize( 8 )
		pt:SetColor( color.r, color.g, color.b )
		--pt:VelocityDecay( false )
		pt:SetGravity( Vector( 0, 0, -math.random( 80 , 200 ) ) )

	end

	emitter:Finish()
	emitter = nil

end

function EFFECT:Think() end
function EFFECT:Render() end
