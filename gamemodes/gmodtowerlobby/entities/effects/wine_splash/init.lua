-----------------------------------------------------
local function CollideCallback( particle, pos, normal )



	/*local decal = "Blood"

	util.Decal( decal, pos + normal, pos - normal )*/



	particle:SetStartSize( 16 )

	particle:SetEndSize( 0 )



	if math.random( 0, 5 ) == 0 then

		sound.Play( "physics/flesh/flesh_bloody_impact_hard1.wav", pos, 60, math.Rand( 70, 140 ) )

	end



end



function EFFECT:Init( data )



	local pos = data:GetOrigin()

	local entity = data:GetEntity()

	local emitter = ParticleEmitter( pos )



	if !IsValid( entity ) then return end



		for i=1, 15 do

			

			local particle = emitter:Add( "effects/splash4", pos + ( VectorRand() * ( entity:BoundingRadius() * 0.15 ) ) )

			if particle then

				particle:SetVelocity( VectorRand():GetNormal() * 40 + Vector(0,0,80) )

				particle:SetDieTime( 10 )

				particle:SetStartAlpha( 255 )

				particle:SetEndAlpha( 0 )

				particle:SetStartSize( math.random( 2, 3 ) )

				particle:SetEndSize( 0.5 )

				particle:SetRoll( math.Rand( 0, 360 ) )

				particle:SetColor( 45 + math.random( 1, 15 ), 0, 6 )

				particle:SetBounce( 0 )

				particle:SetGravity( Vector(0,0,-200) )

				particle:SetCollide( true )

				particle:SetCollideCallback( CollideCallback )

			end



		end



	emitter:Finish()



	if math.random( 0, 5 ) == 0 then

		self:EmitSound( "physics/flesh/flesh_bloody_impact_hard1.wav", 60, math.Rand( 70, 140 ) )

	end

	

end



function EFFECT:Think()

end



function EFFECT:Render()

end