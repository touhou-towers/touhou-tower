
include("shared.lua")

local matBall = Material( "sprites/paintball" )

function ENT:DrawTranslucent()
	render.SetMaterial(matBall)
	local col

	if self:GetNWInt("color") == 0 then
		col = Color(0,0,0,255)
	else
		col = Color(255,255,255,255)
	end

	render.DrawSprite(self:GetPos(), 16, 16, col)
end
