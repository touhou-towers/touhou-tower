
-----------------------------------------------------
EFFECT.Mat		= Material( "effects/spark" )
local matLight	= Material( "effects/yellowflare" )

function EFFECT:Init( data )

	local ent = data:GetEntity()

	self.StartPos	= data:GetStart()
	self.EndPos		= data:GetOrigin()
	self.Dir		= self.EndPos - self.StartPos

	self:SetRenderBoundsWS( self.StartPos, self.EndPos )

	self.TracerTime = 0.1
	self.Length = math.Rand( 0.4, 0.6 )

	self.DieTime = CurTime() + self.TracerTime


	if ConVarDLights:GetInt() < 2 then return end

	// Start
	local dlight = DynamicLight( self:EntIndex() )
	if dlight then
		dlight.Pos = self.StartPos
		dlight.r = 0
		dlight.g = 255
		dlight.b = 0
		dlight.Brightness = 4
		dlight.Decay = 512
		dlight.size = 256
		dlight.DieTime = CurTime() + .5
	end

	// End
	local dlight2 = DynamicLight( self:EntIndex() .. "2" )
	if dlight2 then
		dlight2.Pos = self.EndPos
		dlight2.r = 0
		dlight2.g = 255
		dlight2.b = 0
		dlight2.Brightness = 4
		dlight2.Decay = 512
		dlight2.size = 256
		dlight2.DieTime = CurTime() + .5
	end

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

		color = Color( 50, 255, 50, 255 )

		render.DrawBeam( self.EndPos - self.Dir * (fDelta - sinWave * self.Length ),
			self.EndPos - self.Dir * (fDelta + sinWave * self.Length ),
			1 + sinWave * 10,
			1,
			0,
			Color( color.r, color.g, color.b, color.a )
		)

		render.SetMaterial( matLight )
		render.DrawSprite( self.StartPos, i * 5, i * 5, Color( color.r, color.g, color.b, color.a ) )
		render.DrawSprite( self.EndPos, i * 5, i * 5, Color( color.r, color.g, color.b, color.a ) )
	end
end