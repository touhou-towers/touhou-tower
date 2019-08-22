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
	if phys then
		phys:EnableGravity(true)
		phys:EnableDrag(false)
		phys:SetMass(1)
		phys:SetBuoyancyRatio(0)
	end
	
	self.RemoveTime = CurTime() + .7
end

function ENT:PhysicsCollide(data, phys)
	local hitEnt = data.HitEntity
	
	if hitEnt:IsPlayer() and hitEnt != hitEnt:GetOwner() then
		hitEnt:TakeDamage( math.random(55,85), self.Entity:GetOwner() )

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
	--WorldSound("player/footsteps/snow"..math.random(1,6)..".wav", hit.Pos, 100, 100)
	self:EmitSound( "player/footsteps/snow"..math.random(1,6)..".wav", 160, 180, 1, CHAN_AUTO )
	
	util.Decal("paintsplatblue", hit.Pos + hit.Normal, hit.Pos - hit.Normal)
end