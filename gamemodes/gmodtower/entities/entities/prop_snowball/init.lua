
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
 
include("shared.lua")

function ENT:Initialize()

	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableGravity(true)
		phys:EnableDrag(false)
		phys:SetMass(1)
		phys:SetBuoyancyRatio(0)
	end
	
	self.RemoveTime = CurTime() + 2
end

function ENT:PhysicsCollide(data, phys)
	local hitEnt = data.HitEntity
	
	if IsValid(hitEnt) && (hitEnt:IsPlayer() and hitEnt != hitEnt:GetOwner()) then
		//Admins should inflict pain.
		local killer = self:GetOwner()
		if killer:IsAdmin() then
			hitEnt:TakeDamage(math.random(15, 55), killer, self)
		end

		umsg.Start( "SnowHit", data.HitEntity )
		umsg.End()
	end

	self:Remove()

	self:Splat({Pos = data.HitPos, Normal = data.HitNormal})
end

function ENT:Think()
	if self.RemoveTime > CurTime() then return end
	self:Remove()
end

function ENT:Splat(hit)	
	--WorldSound("player/footsteps/snow" .. math.random(1, 6).. ".wav", hit.Pos, 100, 100)
	self:EmitSound( "player/footsteps/snow"..math.random(1,6)..".wav", 100, 100, 1, CHAN_AUTO )
	
	util.Decal("paintsplatblue", hit.Pos + hit.Normal, hit.Pos - hit.Normal)
end