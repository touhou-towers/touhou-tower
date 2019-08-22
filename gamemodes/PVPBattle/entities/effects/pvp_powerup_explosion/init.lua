EFFECT.FlareMat = Material("effects/yellowflare")

function EFFECT:Init( data )
	local pos = data:GetOrigin()
	local force = math.random( 100, 200 )
	
	local emitter = ParticleEmitter( pos )
	if ( emitter ) then
		for i = 1, 50 do
			local explosion = emitter:Add( "effects/yellowflare", pos )
			local vec = Vector( math.cos( math.Rand( -1, 1 ) ) * math.Rand( -force, force ), math.cos( math.Rand( -1, 1 ) ) * math.Rand( -force, force ), math.cos( math.Rand( -1, 1 ) ) * math.Rand( -force, force ) )
			
			explosion:SetVelocity( vec )
			explosion:SetColor( 220, 220, 220 )
			explosion:SetDieTime( math.Rand( 2, 4 ) )
			explosion:SetStartAlpha( 255 )
			explosion:SetEndAlpha( 0 )
			explosion:SetStartSize( 8 )
			explosion:SetEndSize( 0 )
			explosion:SetAirResistance( 10 )
			explosion:SetGravity( Vector( 0, 0, 100 ) )
			explosion:SetCollide( true )
			explosion:SetBounce( 0.7 )
		end
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end