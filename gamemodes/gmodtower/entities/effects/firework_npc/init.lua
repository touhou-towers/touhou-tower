
function EFFECT:Init( data )

	local pos = data:GetOrigin()
	
	local life = 3
	local life_low = ( life * 0.8 ) * 10
	local life_high = ( life * 1.2 ) * 10
		
	local emitter = ParticleEmitter( pos )
	
	local size = math.random( 5, 20 )
	
	local state = math.random( 1, 3 )
	
	local r = math.random( 1, 255 )
	local g = math.random( 1, 255 )
	local b = math.random( 1, 255 )
	
	for i = 1, 50 do
	
		local pt = emitter:Add( "sprites/powerup_effects", pos )
		
		pt:SetVelocity( VectorRand():GetNormal() * size )
		pt:SetGravity( Vector( 0, 0, -100 ) )
		
		pt:SetDieTime( math.random( life_low, life_high ) * 0.1 )
		pt:SetAirResistance( 150 )
		pt:SetStartAlpha( 255 )
		pt:SetEndAlpha( 0 )
		pt:SetStartSize( 5 )
		pt:SetEndSize( 0 )
		
		if state == 1 then
			pt:SetColor( r, g, b )
		elseif state == 2 && math.random( 1, 2 ) == 1 then
			pt:SetColor( r, g, b )
		else
			pt:SetColor( math.random( 1, 255 ), math.random( 1, 255 ), math.random( 1, 255 ) )
		end
	
		pt:SetStartLength( 10 )
		pt:SetEndLength( 30 )
		
	end
	
end

function EFFECT:Think() end
function EFFECT:Render() end