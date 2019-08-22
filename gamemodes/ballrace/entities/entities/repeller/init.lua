AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

// repel, radius, power
function ENT:KeyValue( key, value )
	if key == "repel" then
		self.Repel = tonumber(value)
	elseif key == "radius" then
		self.Radius = tonumber(value)
	elseif key == "power" then
		self.Power = tonumber(value)
	end
end

function ENT:Initialize()
	self:SetParent(NULL)

	self:SetModel(self.Model)

	self.Entity:PhysicsInit(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end
	
	if !self.Repel then
		self.Repel = 0
	end
	if !self.Radius then
		self.Radius = 256
	end
	if !self.Power then
		self.Power = 1000
	end
	
	if self.Repel <= 0 then
		self:SetSkin(1)
	end
end

function ENT:PhysicsCollide(data, phys)
	if IsValid(data.HitEntity) && data.HitEntity:GetClass() == "player_ball" && self.Repel <= 0 then
		data.HitEntity:GetOwner():Kill()
	end
end