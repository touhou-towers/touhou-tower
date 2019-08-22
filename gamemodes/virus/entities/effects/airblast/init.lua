EFFECT.Mat = Material( "refract_ring" )

function EFFECT:Init( data )

	self.Refract = 0

	self.SizeS = data:GetScale() or 10
	self.Position = data:GetOrigin()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	
	self.Pos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.Entity:SetRenderBounds( Vector() * -512, Vector() * 512 )
	
	self.matLight = Material( "sprites/flamelet" .. tostring( math.random( 1, 5 ) ) )

end

function EFFECT:Think()

	self.Refract = self.Refract + 2.0 * FrameTime()
	self.Size = self.SizeS * self.Refract^(0.2)

	if ( self.Refract >= 1 ) then return false end
	return true

end

function EFFECT:Render()

	self.Mat:SetFloat( "$refractamount", math.sin( self.Refract * math.pi ) * 0.1 )
	render.SetMaterial( self.Mat )
	render.UpdateRefractTexture()
	render.DrawSprite( self.Pos + ( EyePos() - self.Pos ):GetNormal() * EyePos():Distance( self.Pos ) * ( self.Refract^( 0.3 ) ) * 0.8, self.SizeS, self.SizeS / 1.5 )

	for i = 1, self.SizeS do

		local color = Color( 0, 128, 255, 200 )

		render.SetMaterial( self.matLight )
		render.DrawSprite( self.Pos, i, i, Color( color.r, color.g, color.b, color.a ) )

	end

end