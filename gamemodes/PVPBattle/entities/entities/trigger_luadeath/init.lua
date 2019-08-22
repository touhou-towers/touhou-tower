ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize()

	self:SetSolid(SOLID_BBOX)
	self:SetCollisionBoundsWS(Vector( -495.99942016602, -1007.96875, -260.96875 ),Vector( 1844.8577880859, -298.00210571289, 1109.9005126953 ))
	self:SetTrigger(true)

end

function ENT:StartTouch( ply )
	if !ply:IsPlayer() || !ply:Alive() then return end

	ply:Kill()
end

function ENT:EndTouch( ply )
end

function ENT:Touch()
end

function ENT:KeyValue( key, value )
	if key == "parentname" then
		self.Parent = value
	end
end

function ENT:AcceptInput( input, activator, ply )

end
