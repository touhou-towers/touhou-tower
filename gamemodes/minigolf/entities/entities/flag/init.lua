AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetModel(self.Model)
	self.Entity:SetSolid(SOLID_NONE)
	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

	--[[local phys = self.Entity:GetPhysicsObject()
	if(phys and phys:IsValid()) then
		phys:EnableMotion(false)
	end]]
end