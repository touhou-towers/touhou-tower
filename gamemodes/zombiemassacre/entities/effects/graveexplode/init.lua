
-----------------------------------------------------
function EFFECT:Init( data )
	self:SetRenderBounds( Vector()*-786, Vector()*786 )
	local Pos = data:GetOrigin()
	local Norm = data:GetNormal()
	local emitter = ParticleEmitter( Pos + Norm * 32 )
	
	emitter:SetNearClip( 0, 128 )
		for i=0,2 do
			local particle = emitter:Add( "particles/smokey", Pos + Norm * 10 )
				particle:SetVelocity( Norm * math.Rand( 50, 100 ) + VectorRand() * 5 )
				particle:SetDieTime( 8 )
				particle:SetStartAlpha( math.Rand( 195, 200 ) )
				particle:SetStartSize( math.Rand( 32, 64 ) )
				particle:SetEndSize( math.Rand( 64, 128 ) )
				particle:SetColor( 180, 180, 180 )
				particle:SetAirResistance( 100 )
				particle:SetCollide( false )
		end
		for i=0, 2 do
			local particle = emitter:Add( "particles/smokey", Pos + Norm * 32 )
				particle:SetVelocity( Norm * 300 + VectorRand() * 30 )
				particle:SetDieTime( math.Rand( 3, 8 ) )
				particle:SetStartAlpha( 200 )
				particle:SetStartSize( math.Rand( 32, 64 ) )
				particle:SetEndSize( 128 )
				particle:SetRoll( 0 )
				particle:SetColor( 180, 180, 180 )
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