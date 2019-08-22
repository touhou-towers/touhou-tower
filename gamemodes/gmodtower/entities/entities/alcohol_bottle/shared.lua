
AddCSLuaFile("shared.lua")

ENT.Base		= "base_anim"
ENT.Type		= "anim"
ENT.PrintName		= "Alcohol Bottle"

ENT.Model		= Model("models/gmod_tower/boozebottle.mdl")

function ENT:Initialize()
	if CLIENT then return end

	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self.Drank = false
end

function ENT:Use(ply)
	if CLIENT || self.Drank then return end

	self.Drank = true
	ply:Drink()

	self:Remove()

	local Item = GTowerItems:CreateById( ITEMS.empty_bottle )
	local ent = Item:OnDrop()

	ent:SetPos(self:LocalToWorld(self:OBBCenter()))
	ent:SetAngles(self:GetAngles())
	
	ent:Spawn()

	if IsValid(ent:GetPhysicsObject()) then
		ent:GetPhysicsObject():Wake()
	end
end