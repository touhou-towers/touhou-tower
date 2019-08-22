
ENT.Type = "anim"

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.PlayerEquipIndex = 0

function ENT:OnRemove()
	local ply = self:GetOwner()

	//print(ply.CosmeticEquipment, " removing ", self, self.PlayerEquipIndex, ply.CosmeticEquipment[self.PlayerEquipIndex])

	if !ply.CosmeticEquipment then return end

	if self.PlayerEquipIndex > 0 then
		ply.CosmeticEquipment[self.PlayerEquipIndex] = nil
		self.PlayerEquipIndex = 0
	end
end

function ENT:AddToEquipment()
	local ply = self:GetOwner()

	if !ply.CosmeticEquipment then
		ply.CosmeticEquipment = {}
	end

	self.PlayerEquipIndex = table.insert(ply.CosmeticEquipment, self)

	//print(ply.CosmeticEquipment, " adding ", self, self.PlayerEquipIndex, ply.CosmeticEquipment[self.PlayerEquipIndex])
end

concommand.Add("listequipment", function(ply, cmd, args)
	local pl = ply
	if args[1] && #args[1] > 0 then
		pl = player.GetByID(args[1])
	end

	if !IsValid(pl) then print("Invalid player") return end

	PrintTable(pl.CosmeticEquipment)
end)
