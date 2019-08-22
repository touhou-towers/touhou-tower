ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:SetBounds(min, max)
	self:SetCollisionBounds(min, max)
	self:SetTrigger(true)
end

function ENT:Touch( ply )
	if game.GetMap() != "gmt_virus_sewage01" then
		ply:Kill()
	end
end