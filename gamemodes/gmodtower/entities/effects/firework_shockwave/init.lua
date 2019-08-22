
local matRefraction	= Material( "refract_ring" )

function EFFECT:Init( data )

	/*local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
		effectdata:SetNormal( Vector(0,0,0) )
		effectdata:SetMagnitude( 8 )
		effectdata:SetScale( 1 )
		effectdata:SetRadius( 16 )
	util.Effect( "Sparks", effectdata, true, true )*/

	self.Refract = 0
	self.Res = 128
	self.Size = 0

	self.Entity:SetRenderBounds( Vector()*-self.Res, Vector()*self.Res )

end

function EFFECT:Think( )

	self.Refract = self.Refract + 2.0 * FrameTime()
	self.Size = self.Res * self.Refract^(0.2)

	if ( self.Refract >= 1 ) then return false end

	return true

end

function EFFECT:Render()

	local Distance = EyePos():Distance( self.Entity:GetPos() )
	local Pos = self.Entity:GetPos() + (EyePos()-self.Entity:GetPos()):GetNormal() * Distance * (self.Refract^(0.3)) * 0.8

	matRefraction:SetFloat( "$refractamount", math.sin( self.Refract * math.pi ) * 0.1 )
	render.SetMaterial( matRefraction )
	render.UpdateRefractTexture()
	render.DrawSprite( Pos, self.Size, self.Size )

end
