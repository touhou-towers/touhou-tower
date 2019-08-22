
-----------------------------------------------------
function EFFECT:Init( data )
	
	local pos = data:GetOrigin()
	local power = data:GetStart().x

	local ent = data:GetEntity()
	if !IsValid( ent ) then return end
	local color = ent:GetBallColor() * 255
	
	local emitter = ParticleEmitter( pos )
	
		for i=1, ( power / 2 ) do

			local particle = emitter:Add( "sprites/powerup_effects", pos )
			if particle then
				
				particle:SetVelocity( VectorRand():GetNormal() * ( power / 2 ) )

				particle:SetDieTime( 2 )

				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )

				particle:SetStartSize( power / 50 )
				particle:SetEndSize( 0 )

				particle:SetColor( color.r, color.g, color.b, 255 )
				particle:SetGravity( Vector( 0, 0, -200 ) )

				particle:SetCollide( true )
				particle:SetBounce( .1 )
			
			end
			
		end
		
	emitter:Finish()
	
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end