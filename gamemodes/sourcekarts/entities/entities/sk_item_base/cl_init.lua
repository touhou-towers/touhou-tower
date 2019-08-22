
-----------------------------------------------------
include('shared.lua')

function ENT:Initialize()
end

function ENT:Draw()

	self:DrawModel()

	if self:GetVelocity():Length() > 0 then
		self:SetRenderAngles( self:GetVelocity():Angle() )
	end

end

function ENT:DrawTranslucent()
end

function ENT:Think()
end