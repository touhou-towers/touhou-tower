include( "shared.lua" )
function ENT:Draw()
	self:DrawModel()
	local scale = .25
	self:SetModelScale( scale, 0 )
	
end