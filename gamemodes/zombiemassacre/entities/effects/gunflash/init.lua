
-----------------------------------------------------
function EFFECT:Init( data )
	self.Entity:SetRenderBounds( Vector() * -1024, Vector() * 1024 )

	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.DieTime = 0.1
	local randnum = math.random(1, 4)
	local sprite = "effects/muzzleflash"..randnum..".vmt"	

	local Pos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	Pos = Pos + data:GetNormal() * 8

	self.Emitter = ParticleEmitter( Pos )

	local particle = self.Emitter:Add( sprite, Pos )
		particle:SetVelocity( Vector( 0, 0, 0 ) )
		particle:SetDieTime( self.DieTime )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 20 )
		particle:SetEndSize( 0 )
		particle:SetRoll( math.random( -360, 360 ) )
		particle:SetRollDelta( math.random( -200, 200 ) )
		particle:SetColor( 255, 255, 255 )
	self.Emitter:Finish()

	if ConVarDLights:GetInt() < 2 then return end

	local dlight = DynamicLight( self:EntIndex() )
	if dlight then
		dlight.Pos = Pos
		dlight.r = 255
		dlight.g = 255
		dlight.b = 200
		dlight.Brightness = 2
		dlight.Decay = 512
		dlight.size = 256
		dlight.DieTime = CurTime() + .5
	end
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end