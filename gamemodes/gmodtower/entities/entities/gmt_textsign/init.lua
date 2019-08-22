AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_OBB)
	self:SetSolid(SOLID_OBB)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )


	self:SetTrigger(true)

	self:DrawShadow(false)

end
