AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.KVModel)
	self:SetSkin(self.KVSkin)
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()

	if(phys:IsValid()) then
		phys:Wake()
		--phys:EnableMotion(self.KVMotion)
		phys:EnableMotion(false)
	end
end

function ENT:KeyValue( key, value )
	if key == "enablemotion" then
		self.KVMotion = tonumber( value )
	elseif key == "model" then
		self.KVModel = string.Trim( value )
	elseif key == "skin" then
		self.KVSkin = tonumber( value )
	end
end