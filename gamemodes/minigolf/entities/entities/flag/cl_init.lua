include("shared.lua")

function ENT:Think()

	if !self.ZOffset then
		self.ZOffset = 0
	end

	local offset = 0

	for _, ent in pairs( ents.FindInSphere( self:GetHolePos(), 80 ) ) do
		if ent:GetClass() == "golfball" then
			offset = 32
		end
	end

	self.ZOffset = math.Approach( self.ZOffset, offset, FrameTime() * 60 )

	self.Offset = Vector( 0, 0, self.ZOffset )

	// Float up and down a bit
	if self.ZOffset > 0 then
		self.Offset = self.Offset + self:GetAngles():Up() * math.sin( CurTime() * 4 ) * .8
		self:SetAngles( self:GetAngles() + Angle( 0, .5, 0 ) )
	end

end

function ENT:GetHolePos()
	return self:GetOwner():GetPos() + self:GetForward() * 38
end

function ENT:Draw()

	self:DrawModel()

	//if !LocalPlayer():IsPocketed() then
		self:SetPos( self:GetHolePos() + self.Offset )
	//end

end