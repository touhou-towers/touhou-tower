AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:DrawShadow(false)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end
end

function ENT:Use(c, a)
end

util.AddNetworkString("OpenDonation")
util.AddNetworkString("OpenDownload")
