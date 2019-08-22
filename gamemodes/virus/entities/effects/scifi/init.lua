function EFFECT:Init( data )

	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	
	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.EndPos = data:GetOrigin()
	
	local Weapon = data:GetEntity()
	if ( IsValid( Weapon ) ) then
	
		local Owner = Weapon:GetOwner()
		if ( IsValid( Owner ) ) then
			self.Color = Color( 225, 0, 255 )
		end
	
	end
	
	self.matLight = Material ( "sprites/flamelet" .. tostring( math.random( 1, 5 ) ) )

	self.TracerTime = 0.05
	self.DieTime 	= CurTime() + self.TracerTime

end

function EFFECT:Think()

	if CurTime() > self.DieTime then
		return false
	end
	return true

end

function EFFECT:Render( )

	for i = 1, 10 do
		local color = Color( 0, 128, 255, 200 )

		render.SetMaterial( self.matLight )
		render.DrawSprite( self.StartPos, i * 2, i * 2, Color( color.r, color.g, color.b, color.a ) )
	end

end