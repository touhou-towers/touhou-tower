
-----------------------------------------------------
EFFECT.BloodMat = Material( "effects/blood_core" )
EFFECT.SmokeMat = Material( "particles/smokey" )

function EFFECT:Init( data )

	local pos 		= data:GetOrigin()
	local ang	 	= data:GetNormal()
	local Scale 	= data:GetScale() or 0.5
	if Scale == 0 then Scale = 0.5 end

	local emitter = ParticleEmitter( pos )

	local particle = emitter:Add( "effects/blood_core", pos )
	if particle then
		particle:SetDieTime( 0.1 * Scale )
		particle:SetStartAlpha( 250 )
		particle:SetStartSize( 4 * Scale )
		particle:SetEndSize( 16 * Scale )
		particle:SetRoll( math.Rand( 0, 360 ) )
		particle:SetColor( 130, 0, 0 )
	end

	local particle = emitter:Add( "effects/blood_core", pos )
	if particle then
		particle:SetDieTime( 0.1 * Scale )
		particle:SetStartAlpha( 250 )
		particle:SetStartSize( 16 * Scale )
		particle:SetEndSize( 4 * Scale )
		particle:SetRoll( math.Rand( 0, 360 ) )
		particle:SetColor( 30, 0, 0 )
	end

	local particle = emitter:Add( "particles/smokey", pos )
	if particle then
		particle:SetDieTime( math.Rand( .2, .5 ) * Scale )
		particle:SetStartAlpha( 20 )
		particle:SetStartSize( math.Rand( 12, 32 ) * ( Scale / 7 ) )
		particle:SetEndSize( math.Rand( 64, 82 ) * ( Scale / 6 ) )
		particle:SetRollDelta( math.Rand( -0.2, 0.2 ) )
		particle:SetColor( 30, 0, 0 )
	end

	for i=0, 6 do
		self:DoParticle( emitter, pos, ang )
	end

	emitter:Finish()

end

function EFFECT:DoParticle( emitter, pos, ang )

	local particle = emitter:Add( "decals/flesh/blood" .. math.random( 1, 5 ), pos )
	if particle then

		particle:SetVelocity( ang:GetNormal() * math.Rand( 160, 300 ) / 1.8 )

		particle:SetLifeTime( 0 )
		particle:SetDieTime( math.Rand( .2, .5 ) )

		particle:SetStartAlpha( math.Rand( 80, 155 ) )
		particle:SetEndAlpha( 0 )

		local size = math.random( 8, 10 ) / 2
		particle:SetStartSize( size )
		particle:SetEndSize( 0 )

		particle:SetRoll( math.Rand(0, 360) )
		particle:SetRollDelta( math.Rand(-10,10) )
		particle:SetColor( 130, 5, 4 )

		particle.sTime = CurTime() + .2
	
		local function collided( particle, HitPos, Normal )

			if particle.sTime < CurTime() then

				if math.random( 1, 2 ) == 1 then
					util.Decal( "Blood", HitPos + Normal * 2 , HitPos - Normal * 2 )
				end

			end

			size = size + 1
			particle:SetStartSize( size )
			particle:SetDieTime( 0.15 )

		end

		particle:SetCollide( true )
		particle:SetCollideCallback( collided )
		particle:SetBounce( math.Rand( 0.2, 0.9 ) )

		particle:SetAirResistance( math.Rand( 6, 18 ) )
		particle:SetGravity( Vector( 0, 0, math.random( -400, -300 ) ) )

	end

end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end