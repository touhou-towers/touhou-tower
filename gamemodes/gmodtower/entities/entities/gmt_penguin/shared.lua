
ENT.Type = "anim"
ENT.Category = "GMTower"

ENT.PrintName = "Penguin"
ENT.Spawnable = true

function ENT:Squish()

	self:EmitSound(Sound("gmodtower/inventory/move_plush.wav"),70)

	self:SetModelScale(0.9,0.25)
	timer.Simple(0.25,function()
		self:SetModelScale(1,0.25)
	end)

end
