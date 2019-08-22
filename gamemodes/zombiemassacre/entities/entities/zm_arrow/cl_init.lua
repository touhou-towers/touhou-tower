include( "shared.lua" )
function ENT:Draw()
	local parent = self:GetParent()
	if IsValid( parent ) then
		//self:SetPos( parent:GetPos() )
	end
	self:DrawModel()
end