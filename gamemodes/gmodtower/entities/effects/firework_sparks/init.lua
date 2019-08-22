
function EFFECT:Init( data )

	local emitter = ParticleEmitter( data:GetOrigin() )

	for i = 1, 10 do

		local particle = emitter:Add( "effects/spark", data:GetOrigin() )
		particle:SetVelocity( VectorRand() * 5 + Vector( 100, 100, 50 ) )
		particle:SetDieTime( math.random( .5, 2 ) )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 3 )
		particle:SetEndSize( 0 )
		particle:SetColor( math.random( 230, 255 ), math.random( 230, 255 ), math.random( 230, 255 ) )
		particle:SetStartLength( 20 )
		particle:SetEndLength( 0 )
		particle:SetRoll( math.random( 0, 360 ) )
		particle:SetGravity( Vector( 0, 0, -200 ) )
		particle:SetCollide( true )
		particle:SetBounce( 0.25 )

	end

	emitter:Finish()
	emitter = nil
	
end

function EFFECT:Think() end
function EFFECT:Render() end