
-----------------------------------------------------
function EFFECT:Init( data )
	self.Entity:SetRenderBounds( Vector() * -1024, Vector() * 1024 )

	self.Pos = data:GetOrigin() + Vector( 0, 0, 40 )
	self.Emitter = ParticleEmitter( self.Pos )
	
	local particle = self.Emitter:Add( "effects/strider_muzzle", self.Pos )
		particle:SetVelocity( Vector( 0, 0, 0 ) )
		particle:SetDieTime( 1.5 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 100 )
		particle:SetEndSize( 0 )
		particle:SetRoll( math.random( -360, 360 ) )
		particle:SetRollDelta( math.random( -200, 200 ) )
		particle:SetColor( 200, 200, 255 )
	self.Emitter:Finish()

	if ConVarDLights:GetInt() < 1 then return end

	local dlight = DynamicLight( self.Entity:EntIndex() )
	if dlight then
		dlight.Pos = self.Entity:GetPos()
		dlight.r = 200
		dlight.g = 200
		dlight.b = 255
		dlight.Brightness = 4
		dlight.Decay = 128
		dlight.size = 80
		dlight.DieTime = CurTime() + .5
	end
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end
