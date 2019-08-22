
-----------------------------------------------------
EFFECT.Mat		= Material( "trails/physbeam" )

function EFFECT:Init( data )

	local ent = data:GetEntity()

	self.StartPos	= data:GetStart()
	self.EndPos		= data:GetOrigin()
	self.Dir		= self.EndPos - self.StartPos

	self:SetRenderBoundsWS( self.StartPos, self.EndPos )

	self.TracerTime = 0.1
	self.Length = math.Rand( 0.2, 0.5 )

	self.DieTime = CurTime() + self.TracerTime

end

function EFFECT:Think()

	if CurTime() > self.DieTime then
		return false
	end
	return true

end

function EFFECT:Render()

	local fDelta = (self.DieTime - CurTime()) / self.TracerTime
	fDelta = math.Clamp( fDelta, 0, 1 ) ^ 0.5

	local pos = self.StartPos
	local endpos = self.EndPos

	self:SetRenderBoundsWS( pos, endpos )

	render.SetMaterial( self.Mat )
	local sinWave = math.sin( fDelta * math.pi )

	local color = Color( 255, 100, 0, 150 )
	local width = 4

	local rand = math.random( 1, 2 )
	if rand > 1 then
		color = Color( 255, 100, 0, 255 )
		width = 6
	end

	render.DrawBeam( endpos - self.Dir * (fDelta - sinWave * self.Length ),
		endpos - self.Dir * (fDelta + sinWave * self.Length ),
		width + sinWave * 8,
		1,
		0,
		Color( color.r, color.g, color.b, color.a )
	)

end