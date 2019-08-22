
function EFFECT:Init( data )
	local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
		effectdata:SetNormal( Vector(0,0,0) )
		effectdata:SetMagnitude( 2 )
		effectdata:SetScale( 1 )
		effectdata:SetRadius( 128 )
	util.Effect( "HelicopterMegaBomb", effectdata, true, true )

	self.Size = 16
	self.Entity:SetRenderBounds( Vector()*-786, Vector()*786 )

	local Pos = data:GetOrigin()
	local Norm = data:GetNormal()
	local Scale = data:GetScale()
	local Dist = LocalPlayer():GetPos():Distance( Pos )
	local emitter = ParticleEmitter( Pos + Norm * 32 )
	
	emitter:SetNearClip( 0, 128 )
		for i=0,2 do
			local particle = emitter:Add( "particles/smokey", Pos + Norm * 10 )
				particle:SetVelocity( Norm * math.Rand( 50, 100 ) + VectorRand() * 50 )
				particle:SetDieTime( 10 )
				particle:SetStartAlpha( math.Rand( 195, 200 ) )
				particle:SetStartSize( math.Rand( 40, 64 ) )
				particle:SetEndSize( math.Rand( 32, 64 ) )
				particle:SetColor(80,80,80)
				particle:SetAirResistance( 100 )
				particle:SetCollide( false )
		end
		for i=0, 2 do
			local particle = emitter:Add( "particles/smokey", Pos + Norm * 32 )
				particle:SetVelocity( Norm * 300 + VectorRand() * 200 )
				particle:SetDieTime( math.Rand( 7, 12 ) )
				particle:SetStartAlpha( 200 )
				particle:SetStartSize( math.Rand( 32,64 ) )
				particle:SetEndSize( 84 )
				particle:SetRoll( 0 )
				particle:SetColor(80,80,80)
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