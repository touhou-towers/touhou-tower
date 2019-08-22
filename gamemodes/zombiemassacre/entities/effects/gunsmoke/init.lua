
-----------------------------------------------------
function EFFECT:Init( data )
	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()

	local Pos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	local Velocity 	= data:GetNormal()
	Velocity.z = 0

	Pos = Pos + data:GetNormal() * 8

	local LightColor = render.GetLightColor( Pos ) * 255
	LightColor.r = math.Clamp( LightColor.r, 90, 255 )
	LightColor.g = math.Clamp( LightColor.g, 90, 255 )
	LightColor.b = math.Clamp( LightColor.b, 90, 255 )
	
	local emitter = ParticleEmitter( Pos )
	local particle = emitter:Add( "particles/smokey", Pos )

	particle:SetVelocity( Velocity * math.Rand( 1, 10 ) )
	particle:SetDieTime( math.Rand( .25, 1 ) )
	particle:SetStartAlpha( math.Rand( 20, 80 ) )
	particle:SetStartSize( math.Rand( 2, 8 ) )
	particle:SetEndSize( math.Rand( 12, 24 ) )
	particle:SetRoll( math.Rand( -25, 25 ) )
	particle:SetRollDelta( math.Rand( -0.1, 0.1 ) )
	particle:SetColor( LightColor.r, LightColor.g, LightColor.b )

	emitter:Finish()
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end