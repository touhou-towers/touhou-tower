
EFFECT.Mat = Material( "refract_ring" )

function EFFECT:Init( data )
	self.Refract = 0

	self.Size = data:GetScale()
	self.Sizez = data:GetScale()
	self.Entity:SetRenderBounds( Vector()*-512, Vector()*512 )
end

function EFFECT:Think()
	self.Refract = self.Refract + 2.0 * FrameTime()
	self.Size = 50 * self.Refract^(0.2)

	if ( self.Refract >= 1 ) then return false end
	return true
end

function EFFECT:Render()
	self.Mat:SetMaterialFloat("$refractamount", math.sin(self.Refract * math.pi) * 0.1)
	render.SetMaterial(self.Mat)
	render.UpdateRefractTexture()
	render.DrawSprite(self.Entity:GetPos() + (EyePos()-self.Entity:GetPos()):GetNormal() * EyePos():Distance(self.Entity:GetPos()) * (self.Refract^(0.3)) * 0.8, self.Size, self.Size)
end