include( "shared.lua" )

local matpoint = Material( "sprites/gmdm_pickups/light" )

function ENT:Initialize()

	self.NextGlowIncrease = 0

end

function ENT:Draw()

	self:DrawModel()
	
	local pos = self:GetPos()
	local size = self.GlowSize

	render.SetMaterial( matpoint )
	
	color = Color( 255, 0, 0, 255 )
	render.DrawSprite( pos, size, size, color )

end

function ENT:Think()

	if CurTime() >= self.NextGlowIncrease then

		self.GlowSize = math.random( 30, 80 )
		self.NextGlowIncrease = CurTime() + math.random( 1, 3 ) / 10

	end

	if self.GlowSize > 150 then self.GlowSize = self.GlowSize - 10 end

end