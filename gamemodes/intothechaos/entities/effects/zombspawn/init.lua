
-----------------------------------------------------
function EFFECT:Init( data )

	self:SetRenderBounds( Vector() * -786, Vector() * 786 )

	local Pos = data:GetOrigin()
	local Norm = data:GetNormal()
	local emitter = ParticleEmitter( Pos + Norm * 32 )

	emitter:SetNearClip( 0, 128 )

	for i=0,2 do

		local particle = emitter:Add( "particles/smokey", Pos + Norm * 10 )
		particle:SetVelocity( Norm * math.Rand( 50, 100 ) + VectorRand() * 5 )
		particle:SetDieTime( 4 )
		particle:SetStartAlpha( math.Rand( 195, 200 ) )
		particle:SetStartSize( math.Rand( 32, 64 ) )
		particle:SetEndSize( math.Rand( 64, 128 ) )
		local dark = math.random( 0, 50 )
		particle:SetColor( dark, dark, dark )
		particle:SetAirResistance( 100 )
		particle:SetCollide( false )

	end

	for i=0, 2 do

		local particle = emitter:Add( "particles/smokey", Pos + Norm * 32 )
		particle:SetVelocity( Norm * 300 + VectorRand() * 30 )
		particle:SetDieTime( math.Rand( 2, 4 ) )
		particle:SetStartAlpha( 200 )
		particle:SetStartSize( math.Rand( 32, 64 ) )
		particle:SetEndSize( 128 )
		particle:SetRoll( 0 )
		local dark = math.random( 0, 50 )
		particle:SetColor( dark, dark, dark )
		particle:SetGravity( Vector( 0, 0, math.Rand( -200, -150 ) ) )
		particle:SetAirResistance( 100 )
		particle:SetCollide( false )

	end

	emitter:Finish()

end

function EFFECT:Think( )
end

function EFFECT:Render()
end