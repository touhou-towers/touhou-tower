
-----------------------------------------------------
//local decal = Material( "Decals/tread" )

local function CollideCallback( particle, pos, normal )

	//util.Decal( "Antlion.Splat", pos + normal, pos - normal )
	//local decal = Material( "decals/greenpaint0" .. math.random( 1, 4 ) )
	//util.DecalEx( decal, GetWorldEntity(), pos + normal, pos - normal, Color(255, 0, 255), 1, 1 )

	particle:SetStartSize( 10 )
	particle:SetEndSize( 0 )

	if math.random( 0, 5 ) == 0 then
		sound.Play( "physics/flesh/flesh_bloody_impact_hard1.wav", pos, 100, math.Rand( 70, 140 ) )
	end
	
end 

function EFFECT:Init( data )
	
	local Pos = data:GetOrigin()
	local count = 30

	local emitter = ParticleEmitter( Pos )

		for i = 0, count do
			
			local particle = emitter:Add( "sprites/paintball", Pos )
			if particle then
				particle:SetVelocity( VectorRand() * 100 + Vector(0,0,50) )
				particle:SetDieTime( 15 )
				particle:SetStartAlpha( 200 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.random( 2, 3 ) )
				particle:SetEndSize( 0.5 )
				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetColor( 125, 231, 156 )
				particle:SetBounce( 0 )
				particle:SetGravity( Vector(0,0,-200) )
				particle:SetCollide( true )
				particle:SetCollideCallback( CollideCallback )
			end

		end

	emitter:Finish()

	if math.random( 0, 5 ) == 0 then
		self:EmitSound( "physics/flesh/flesh_bloody_impact_hard1.wav", 100, math.Rand( 70, 140 ) )
	end
	
end

function EFFECT:Think()
end

function EFFECT:Render()
end