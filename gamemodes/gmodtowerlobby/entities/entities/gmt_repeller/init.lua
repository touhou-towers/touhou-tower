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
end

function ENT:DoShieldPush(entity, force)
	entity:SetVelocity((entity:GetPos() - self:GetPos()):GetNormalized() * force)
end

function ENT:Think()
    for k,v in pairs(ents.FindInSphere( self:GetPos(), 256 )) do
			if ( IsValid(v) and v:IsPlayer() and v:Alive() ) then
				local dist = v:GetPos():Distance(self:GetPos())
				self:DoShieldPush( v, self.Power / (dist/32) )
			end
		end
end
