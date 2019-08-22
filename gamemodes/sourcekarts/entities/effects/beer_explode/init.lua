
-----------------------------------------------------
EFFECT.Mat = Material("effects/bubble")

// hiccup bubbles
function EFFECT:Init( data )

	local pos = data:GetOrigin()
	
	local emitter = ParticleEmitter( pos )
	
	for i = 1, 64 do
		local particle = emitter:Add( "effects/bubble", pos )
		particle:SetVelocity( ( Vector( 0, 0, 1 ) + ( VectorRand():GetNormal() * 5 ) ) * math.random( 15, 45 ) )
		particle:SetDieTime( math.random( 0.5, 1.5 ) )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 8 )
		particle:SetEndSize( 0.1 )
		particle:SetRoll( 0 )
		particle:SetRollDelta( 0 )
		particle:SetColor( 255, 255, 255 )
	end
	
	emitter:Finish()

end

function EFFECT:Think( )
	return false
end

function EFFECT:Render( )
end