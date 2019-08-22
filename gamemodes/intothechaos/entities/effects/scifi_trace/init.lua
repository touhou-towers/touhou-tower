EFFECT.Mat		= Material( "trails/physbeam" )
local matLight	= Material( "effects/yellowflare" )

function EFFECT:Init( data )
	local ent = data:GetEntity()

	self.StartPos	= data:GetStart()
	self.EndPos		= data:GetOrigin()
	self.Dir		= self.EndPos - self.StartPos

	self:SetRenderBoundsWS( self.StartPos, self.EndPos )

	self.TracerTime = 0.15
	self.Length = math.Rand( 0.1, 0.2 )

	self.DieTime = CurTime() + self.TracerTime
end

function EFFECT:Think( )
	if CurTime() > self.DieTime then
		return false
	end
	return true
end

function EFFECT:Render( )
	local fDelta = (self.DieTime - CurTime()) / self.TracerTime
	fDelta = math.Clamp( fDelta, 0, 1 ) ^ 0.5

	for i = 1, 10 do
		render.SetMaterial( self.Mat )
		local sinWave = math.sin( fDelta * math.pi )

		local color		

		color = Color( 0, 195, 255, 10 )

		render.DrawBeam( self.EndPos - self.Dir * (fDelta - sinWave * self.Length ),
			self.EndPos - self.Dir * (fDelta + sinWave * self.Length ),
			1 + sinWave * 8,
			1,
			0,
			Color( color.r, color.g, color.b, color.a )
		)

		render.SetMaterial( matLight )
		render.DrawSprite( self.StartPos, i * 8, i * 8, Color( color.r, color.g, color.b, color.a ) )
		render.DrawSprite( self.EndPos, i * 4, i * 4, Color( color.r, color.g, color.b, color.a ) )
	end
end