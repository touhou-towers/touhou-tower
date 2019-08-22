EFFECT.Mat = Material("effects/yellowflare")

function EFFECT:Init( data )

	local pos = data:GetOrigin()
	local force = math.random( 200, 250 )

	local emitter = ParticleEmitter( pos )
	
		for i=1, 55 do
		
			local particle = emitter:Add( "effects/yellowflare", pos )
			if (particle) then

				particle:SetVelocity( Vector(math.Rand(-1,1), math.Rand(-1,1), math.Rand(0,1)) * force )
				
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 2, 3 ) )
				
				//particle:SetColor( 255, 230, 50 )

				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				
				particle:SetStartSize( 25 )
				particle:SetEndSize( 6 )
				
				particle:SetCollide( true )
				particle:SetBounce( 2 )

				particle:SetAirResistance( 50 )
				particle:SetGravity(Vector(0,0, -180))
			
			end
			
		end
		
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end