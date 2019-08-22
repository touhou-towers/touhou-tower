
include("shared.lua")

function ENT:Draw()
	self:SetModelScale(.5)
	self:DrawModel()
end
